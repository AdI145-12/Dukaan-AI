import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImagePipeline {
  ImagePipeline._();

  /// Full pipeline: read -> resize -> compress -> return bytes.
  /// Runs in an isolate via compute so UI thread remains free.
  static Future<Uint8List> prepareForUpload(XFile imageFile) async {
    final Uint8List inputBytes = await imageFile.readAsBytes();
    return compute<Uint8List, Uint8List>(_runPipeline, inputBytes);
  }

  /// Converts bytes to base64 in an isolate.
  static Future<String> toBase64(Uint8List bytes) {
    return compute<Uint8List, String>(_encodeBase64, bytes);
  }
}

Uint8List _runPipeline(Uint8List inputBytes) {
  final img.Image? decoded = img.decodeImage(inputBytes);
  if (decoded == null) {
    throw Exception('Image decode nahi hua.');
  }

  img.Image resized = decoded;
  if (decoded.width > 1080) {
    resized = img.copyResize(decoded, width: 1080);
  }

  Uint8List compressed = Uint8List.fromList(
    img.encodeJpg(resized, quality: 82),
  );

  if (compressed.length > 500 * 1024) {
    compressed = Uint8List.fromList(
      img.encodeJpg(resized, quality: 70),
    );
  }

  assert(() {
    final String originalKb = (inputBytes.length / 1024).toStringAsFixed(1);
    final String finalKb = (compressed.length / 1024).toStringAsFixed(1);
    final double reduction = inputBytes.isEmpty
        ? 0
        : (1 - compressed.length / inputBytes.length) * 100;
    final String ratio = reduction.toStringAsFixed(0);

    debugPrint('[ImagePipeline] ${originalKb}KB -> ${finalKb}KB (-$ratio%)');
    return true;
  }());

  return compressed;
}

String _encodeBase64(Uint8List bytes) => base64Encode(bytes);
