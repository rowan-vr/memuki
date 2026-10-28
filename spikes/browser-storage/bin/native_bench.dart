import 'dart:convert';
import 'dart:io';

import 'package:browser_storage_spike/bench.dart';
import 'package:browser_storage_spike/db.dart';
import 'package:drift/native.dart';

/// Usage: dart run bin/native_bench.dart <jitendex dir> <out dir> [--content]
Future<void> main(List<String> args) async {
  final dictDir = args[0];
  final outDir = Directory(args[1])..createSync(recursive: true);
  final storeContent = args.contains('--content');
  for (final f in outDir.listSync()) {
    f.deleteSync();
  }
  final banks = Directory(dictDir)
      .listSync()
      .where((f) => f.path.contains('term_bank_'))
      .length;

  final app = AppDb(NativeDatabase.createInBackground(File('${outDir.path}/app.db')));
  final dict = DictDb(NativeDatabase.createInBackground(File('${outDir.path}/dict.db')));
  final result = <String, Object?>{
    'platform': 'native',
    'storeContent': storeContent,
    'features': await featureChecks(app),
    'app': await appWrites(app),
    'dict': await dictImport(
      dict,
      (bank) => File('$dictDir/term_bank_$bank.json').readAsString(),
      banks,
      storeContent: storeContent,
      log: stderr.writeln,
    ),
    'queries': await dictQueries(dict),
    'appBytes': await dbBytes(app),
    'dictBytes': await dbBytes(dict),
  };
  await app.close();
  await dict.close();
  print(const JsonEncoder.withIndent('  ').convert(result));
}
