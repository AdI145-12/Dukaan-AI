import 'dart:typed_data';

sealed class CaptureState {
  const CaptureState();
}

class CaptureInitial extends CaptureState {
  const CaptureInitial();
}

class CaptureImageReady extends CaptureState {
  const CaptureImageReady({
    required this.imageBytes,
    required this.base64Image,
  });

  final Uint8List imageBytes;
  final String base64Image;
}

class CaptureProcessing extends CaptureState {
  const CaptureProcessing({required this.imageBytes});

  final Uint8List imageBytes;
}

class CaptureProcessed extends CaptureState {
  const CaptureProcessed({required this.processedBase64});

  final String processedBase64;
}

class CaptureError extends CaptureState {
  const CaptureError({required this.message});

  final String message;
}
