import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'background_select_state.freezed.dart';

@freezed
abstract class BackgroundSelectState with _$BackgroundSelectState {
  factory BackgroundSelectState({
    int? selectedStyleIndex,
    @Default('') String customPrompt,
    @Default(false) bool isGenerating,
    String? error,
    GeneratedAd? generatedAd,
  }) = _BackgroundSelectState;
}
