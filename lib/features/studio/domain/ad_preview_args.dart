import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';

class AdPreviewArgs {
  const AdPreviewArgs({
    required this.generatedAd,
    required this.processedBase64,
    required this.backgroundStyleId,
    this.customPrompt,
  });

  final GeneratedAd generatedAd;
  final String processedBase64;
  final String backgroundStyleId;
  final String? customPrompt;
}