import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogue_state.freezed.dart';

@freezed
abstract class CatalogueState with _$CatalogueState {
	const factory CatalogueState({
		@Default(false) bool isSubmitting,
		@Default(false) bool isGeneratingMetadata,
		@Default('') String description,
		@Default(<String>[]) List<String> tags,
		@Default(<String>[]) List<String> suggestedCaptions,
		String? lastGeneratedKey,
		String? errorMessage,
	}) = _CatalogueState;
}