import 'package:freezed_annotation/freezed_annotation.dart';

part 'ad_creation_request.freezed.dart';

@freezed
abstract class AdCreationRequest with _$AdCreationRequest {
  const factory AdCreationRequest({
    required String processedImageBase64,
    required String backgroundStyleId,
    required String userId,
    String? customPrompt,
  }) = _AdCreationRequest;
}
