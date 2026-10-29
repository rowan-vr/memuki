import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:memuki/storage/media/media_store.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import 'src/runner.dart';
import 'src/session.dart';

/// Developer tool for Memuki data. Run `fvm dart run tool/memuki.dart help`.
Future<void> main(List<String> args) async {
  try {
    await MemukiRunner().run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  } on ToolException catch (e) {
    stderr.writeln(e);
    exitCode = 1;
  } on RepositoryException catch (e) {
    stderr.writeln(e);
    exitCode = 1;
  } on MediaFileNotFoundException catch (e) {
    stderr.writeln(e);
    exitCode = 1;
  }
}
