import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/application/background_select_state.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/background_style.dart';
import 'package:dukaan_ai/features/studio/infrastructure/ad_generation_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_select_provider.g.dart';

@riverpod
class BackgroundSelect extends _$BackgroundSelect {
  @override
  BackgroundSelectState build() => BackgroundSelectState();

  /// Selects one background style index from [BackgroundStyle.all].
  void selectStyle(int index) {
    state = state.copyWith(
      selectedStyleIndex: index,
      error: null,
    );
  }

  /// Updates optional custom prompt text.
  void updatePrompt(String prompt) {
    state = state.copyWith(customPrompt: prompt);
  }

  /// Generates ad for selected style and processed image.
  Future<void> generateAd({required String processedBase64}) async {
    final int? selectedIndex = state.selectedStyleIndex;
    if (selectedIndex == null) {
      return;
    }

    final String userId = FirebaseService.currentUserId ?? '';
    final BackgroundStyle style = BackgroundStyle.all[selectedIndex];

    state = state.copyWith(
      isGenerating: true,
      error: null,
    );

    try {
      final AdGenerationService service = ref.read(adGenerationServiceProvider);
      final result = await service.generateAd(
        AdCreationRequest(
          processedImageBase64: processedBase64,
          backgroundStyleId: style.id,
          customPrompt: state.customPrompt.isEmpty ? null : state.customPrompt,
          userId: userId,
        ),
      );

      state = state.copyWith(
        isGenerating: false,
        generatedAd: result,
      );
      ref.invalidate(studioProvider);
    } on AppException catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.userMessage,
      );
    } catch (_) {
      state = state.copyWith(
        isGenerating: false,
        error: AppStrings.errorGeneric,
      );
    }
  }
}
