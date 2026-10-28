import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

final _log = Logger('memuki.error');

/// Routes uncaught errors to the logger.
///
/// - Framework errors (build, layout, paint) go through [FlutterError.onError].
///   In debug builds they are also dumped to the console in Flutter's usual
///   detailed format.
/// - Uncaught asynchronous errors go through [PlatformDispatcher.onError].
void installErrorHandlers() {
  FlutterError.onError = (details) {
    _log.severe(
      'Framework error: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  WidgetsFlutterBinding.ensureInitialized().platformDispatcher.onError =
      (error, stack) {
        _log.shout('Uncaught error', error, stack);
        return true;
      };
}
