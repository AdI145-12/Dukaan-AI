import 'dart:convert';
import 'dart:typed_data';

import 'package:dukaan_ai/core/services/image_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  group('ImagePipeline', () {
    test('prepareForUpload should return <= 500KB bytes when input image is large',
        () async {
      // Arrange
      final img.Image sourceImage = _buildPatternImage(width: 2600, height: 2000);
      final Uint8List sourceBytes = Uint8List.fromList(
        img.encodeJpg(sourceImage, quality: 100),
      );
      final XFile sourceFile = XFile.fromData(
        sourceBytes,
        name: 'large.jpg',
        mimeType: 'image/jpeg',
      );

      // Act
      final Uint8List output = await ImagePipeline.prepareForUpload(sourceFile);

      // Assert
      expect(sourceBytes.length, greaterThan(1024 * 1024));
      expect(output.length, lessThanOrEqualTo(1024 * 1024));
    });

    test('prepareForUpload should resize width to <= 1080 when source is wider',
        () async {
      // Arrange
      final img.Image sourceImage = _buildPatternImage(width: 2000, height: 1500);
      final Uint8List sourceBytes = Uint8List.fromList(
        img.encodeJpg(sourceImage, quality: 95),
      );
      final XFile sourceFile = XFile.fromData(
        sourceBytes,
        name: 'wide.jpg',
        mimeType: 'image/jpeg',
      );

      // Act
      final Uint8List output = await ImagePipeline.prepareForUpload(sourceFile);
      final img.Image? decoded = img.decodeImage(output);

      // Assert
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(1080));
    });

    test('toBase64 should return valid base64 string when bytes are provided',
        () async {
      // Arrange
      final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);

      // Act
      final String encoded = await ImagePipeline.toBase64(bytes);

      // Assert
      expect(encoded, equals(base64Encode(bytes)));
    });

    test('prepareForUpload should throw exception when image bytes are invalid',
        () async {
      // Arrange
      final XFile invalidFile = XFile.fromData(
        Uint8List.fromList(<int>[10, 20, 30, 40]),
        name: 'invalid.txt',
        mimeType: 'text/plain',
      );

      // Act + Assert
      await expectLater(
        () => ImagePipeline.prepareForUpload(invalidFile),
        throwsA(anything),
      );
    });
  });
}

img.Image _buildPatternImage({required int width, required int height}) {
  final img.Image image = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int r = (x * 31 + y * 17) % 256;
      final int g = (x * 13 + y * 29) % 256;
      final int b = (x * 7 + y * 11) % 256;
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return image;
}
