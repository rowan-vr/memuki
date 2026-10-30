import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the Developer destination and its tools are available. True only
/// in debug builds.
final developerToolsProvider = Provider<bool>((ref) => kDebugMode);
