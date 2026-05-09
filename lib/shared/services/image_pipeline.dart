import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImagePipeline {
  ImagePipeline._();

  /// Compresses [imageFile] to max 800px width, quality 85.
  /// Runs in Isolate via compute — never blocks UI thread.
  static Future<Uint8List> compress(XFile imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    return compute<
        _CompressParams,
        Uint8List>(
      _compressInIsolate,
      _CompressParams(
        bytes: bytes,
        maxWidth: 800,
        quality: 85,
      ),
    );
  }

  /// Converts bytes to base64 string in an Isolate.
  static Future<String> toBase64(Uint8List bytes) async {
    return compute<Uint8List, String>(_base64InIsolate, bytes);
  }
}

class _CompressParams {
  const _CompressParams({
    required this.bytes,
    required this.maxWidth,
    required this.quality,
  });

  final Uint8List bytes;
  final int maxWidth;
  final int quality;
}

Uint8List _compressInIsolate(_CompressParams params) {
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(params.bytes);
  } catch (_) {
    return params.bytes;
  }

  if (decoded == null) {
    return params.bytes;
  }

  final int targetWidth =
      decoded.width > params.maxWidth ? params.maxWidth : decoded.width;
  final img.Image resized = img.copyResize(decoded, width: targetWidth);
  final List<int> encoded = img.encodeJpg(resized, quality: params.quality);
  return Uint8List.fromList(encoded);
}

String _base64InIsolate(Uint8List bytes) {
  return base64Encode(bytes);
}
