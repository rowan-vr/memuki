import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'edit_commands.dart';
import 'inspect_commands.dart';
import 'maintenance_commands.dart';
import 'session.dart';

/// The `memuki` developer tool: inspects and edits a Memuki database through
/// the app's repositories.
class MemukiRunner extends CommandRunner<void> {
  MemukiRunner({StringSink? out})
    : out = out ?? stdout,
      super(
        'memuki',
        'Inspect, generate, and edit Memuki data without the app.\n\n'
            'Works on the app database by default. Close the app while '
            'editing: it does not notice changes made by other programs.',
      ) {
    final dataDir = defaultDataDirectory();
    argParser
      ..addOption(
        'db',
        help: 'Database file.',
        defaultsTo: dataDir == null ? null : p.join(dataDir, 'memuki.sqlite'),
      )
      ..addOption(
        'media',
        help: 'Media folder. Defaults to "media" next to the database.',
      );
    for (final command in [
      ...inspectCommands(),
      ...editCommands(),
      ...maintenanceCommands(),
    ]) {
      addCommand(command);
    }
  }

  final StringSink out;

  /// Opens the database and media folder that [options] point to.
  Future<Session> openSession(ArgResults options) {
    final path = options['db'] as String?;
    if (path == null) throw UsageException('Pass --db.', usage);
    final dbFile = File(path);
    final media = options['media'] as String?;
    return Session.open(
      dbFile: dbFile,
      mediaDir: Directory(media ?? p.join(dbFile.parent.path, 'media')),
      out: out,
    );
  }
}

/// A command that runs against an open [Session].
abstract class SessionCommand extends Command<void> {
  Future<void> runIn(Session session);

  @override
  Future<void> run() async {
    final session = await (runner! as MemukiRunner).openSession(globalResults!);
    try {
      await runIn(session);
    } finally {
      await session.close();
    }
  }

  /// The positional argument at [index], named [name] in the error.
  String arg(int index, String name) {
    final rest = argResults!.rest;
    if (rest.length <= index) usageException('Missing <$name>.');
    return rest[index];
  }

  /// The positional arguments from [index] on.
  List<String> argsFrom(int index) => argResults!.rest.skip(index).toList();

  String? option(String name) => argResults![name] as String?;

  bool flag(String name) => argResults![name] as bool;
}

/// A command that only groups subcommands, like `deck add`.
class GroupCommand extends Command<void> {
  GroupCommand(this.name, this.description, List<Command<void>> commands) {
    commands.forEach(addSubcommand);
  }

  @override
  final String name;

  @override
  final String description;
}

/// A [SessionCommand] defined by a function, with its positional arguments
/// in [arguments] for the usage text (for example `<deck> <name>`).
class ActionCommand extends SessionCommand {
  ActionCommand(
    this.name,
    this.description,
    this._action, {
    this.arguments = '',
    void Function(ArgParser parser)? options,
  }) {
    options?.call(argParser);
  }

  @override
  final String name;

  @override
  final String description;

  final String arguments;
  final Future<void> Function(ActionCommand command, Session session) _action;

  @override
  String get invocation {
    final path = [for (Command<void>? c = this; c != null; c = c.parent) c.name]
        .reversed
        .join(' ');
    return '${runner!.executableName} $path [options] $arguments'.trimRight();
  }

  @override
  Future<void> runIn(Session session) => _action(this, session);
}
