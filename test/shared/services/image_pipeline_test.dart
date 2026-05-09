import 'dart:convert';
import 'dart:typed_data';

import 'package:dukaan_ai/shared/services/image_pipeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  group('ImagePipeline', () {
    test('compress should resize image to max width 800 when input is wider',
        () async {
      // Arrange
      final img.Image sourceImage = img.Image(width: 1200, height: 600);
      final Uint8List sourceBytes = Uint8List.fromList(
        img.encodeJpg(sourceImage, quality: 95),
      );
      final XFile sourceFile = XFile.fromData(
        sourceBytes,
        name: 'source.jpg',
        mimeType: 'image/jpeg',
      );

      // Act
      final Uint8List compressedBytes = await ImagePipeline.compress(sourceFile);
      final img.Image? decodedCompressed = img.decodeImage(compressedBytes);

      // Assert
      expect(decodedCompressed, isNotNull);
      expect(decodedCompressed!.width, lessThanOrEqualTo(800));
      expect(decodedCompressed.height, lessThanOrEqualTo(600));
    });

    test('compress should return original bytes when image decoding fails', () async {
      // Arrange
      final Uint8List invalidBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);
      final XFile invalidFile = XFile.fromData(
        invalidBytes,
        name: 'invalid.jpg',
        mimeType: 'image/jpeg',
      );

      // Act
      final Uint8List result = await ImagePipeline.compress(invalidFile);

      // Assert
      expect(result, orderedEquals(invalidBytes));
    });

    test('toBase64 should encode bytes to base64 string', () async {
      // Arrange
      final Uint8List bytes = Uint8List.fromList(<int>[10, 20, 30, 40]);

      // Act
      final String encoded = await ImagePipeline.toBase64(bytes);

      // Assert
      expect(encoded, base64Encode(bytes));
    });
  });
}
