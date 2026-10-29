import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';

part 'media_asset.freezed.dart';

/// A media file used by notes in a collection. Files are content-addressed:
/// the asset's identity within its collection is its [hash], so identical
/// files are stored once.
@freezed
abstract class MediaAsset with _$MediaAsset {
  MediaAsset._() {
    if (sizeBytes < 0) {
      throw ArgumentError.value(sizeBytes, 'sizeBytes', 'must not be negative');
    }
    if (mimeType.isEmpty) {
      throw ArgumentError.value(mimeType, 'mimeType', 'must not be empty');
    }
  }

  factory MediaAsset({
    required CollectionId collectionId,
    required ContentHash hash,
    required String mimeType,
    required int sizeBytes,
    String? originalName,
  }) = _MediaAsset;
}
