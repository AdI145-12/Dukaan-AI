// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogueState {
  bool get isSubmitting;
  bool get isGeneratingMetadata;
  String get description;
  List<String> get tags;
  List<String> get suggestedCaptions;
  String? get lastGeneratedKey;
  String? get errorMessage;

  /// Create a copy of CatalogueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CatalogueStateCopyWith<CatalogueState> get copyWith =>
      _$CatalogueStateCopyWithImpl<CatalogueState>(
          this as CatalogueState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CatalogueState &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isGeneratingMetadata, isGeneratingMetadata) ||
                other.isGeneratingMetadata == isGeneratingMetadata) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.suggestedCaptions, suggestedCaptions) &&
            (identical(other.lastGeneratedKey, lastGeneratedKey) ||
                other.lastGeneratedKey == lastGeneratedKey) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSubmitting,
      isGeneratingMetadata,
      description,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(suggestedCaptions),
      lastGeneratedKey,
      errorMessage);

  @override
  String toString() {
    return 'CatalogueState(isSubmitting: $isSubmitting, isGeneratingMetadata: $isGeneratingMetadata, description: $description, tags: $tags, suggestedCaptions: $suggestedCaptions, lastGeneratedKey: $lastGeneratedKey, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $CatalogueStateCopyWith<$Res> {
  factory $CatalogueStateCopyWith(
          CatalogueState value, $Res Function(CatalogueState) _then) =
      _$CatalogueStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isSubmitting,
      bool isGeneratingMetadata,
      String description,
      List<String> tags,
      List<String> suggestedCaptions,
      String? lastGeneratedKey,
      String? errorMessage});
}

/// @nodoc
class _$CatalogueStateCopyWithImpl<$Res>
    implements $CatalogueStateCopyWith<$Res> {
  _$CatalogueStateCopyWithImpl(this._self, this._then);

  final CatalogueState _self;
  final $Res Function(CatalogueState) _then;

  /// Create a copy of CatalogueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSubmitting = null,
    Object? isGeneratingMetadata = null,
    Object? description = null,
    Object? tags = null,
    Object? suggestedCaptions = null,
    Object? lastGeneratedKey = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingMetadata: null == isGeneratingMetadata
          ? _self.isGeneratingMetadata
          : isGeneratingMetadata // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestedCaptions: null == suggestedCaptions
          ? _self.suggestedCaptions
          : suggestedCaptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastGeneratedKey: freezed == lastGeneratedKey
          ? _self.lastGeneratedKey
          : lastGeneratedKey // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CatalogueState].
extension CatalogueStatePatterns on CatalogueState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CatalogueState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CatalogueState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CatalogueState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool isSubmitting,
            bool isGeneratingMetadata,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            String? lastGeneratedKey,
            String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueState() when $default != null:
        return $default(
            _that.isSubmitting,
            _that.isGeneratingMetadata,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
            _that.lastGeneratedKey,
            _that.errorMessage);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            bool isSubmitting,
            bool isGeneratingMetadata,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            String? lastGeneratedKey,
            String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueState():
        return $default(
            _that.isSubmitting,
            _that.isGeneratingMetadata,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
            _that.lastGeneratedKey,
            _that.errorMessage);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool isSubmitting,
            bool isGeneratingMetadata,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            String? lastGeneratedKey,
            String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueState() when $default != null:
        return $default(
            _that.isSubmitting,
            _that.isGeneratingMetadata,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
            _that.lastGeneratedKey,
            _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CatalogueState implements CatalogueState {
  const _CatalogueState(
      {this.isSubmitting = false,
      this.isGeneratingMetadata = false,
      this.description = '',
      final List<String> tags = const <String>[],
      final List<String> suggestedCaptions = const <String>[],
      this.lastGeneratedKey,
      this.errorMessage})
      : _tags = tags,
        _suggestedCaptions = suggestedCaptions;

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isGeneratingMetadata;
  @override
  @JsonKey()
  final String description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _suggestedCaptions;
  @override
  @JsonKey()
  List<String> get suggestedCaptions {
    if (_suggestedCaptions is EqualUnmodifiableListView)
      return _suggestedCaptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedCaptions);
  }

  @override
  final String? lastGeneratedKey;
  @override
  final String? errorMessage;

  /// Create a copy of CatalogueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CatalogueStateCopyWith<_CatalogueState> get copyWith =>
      __$CatalogueStateCopyWithImpl<_CatalogueState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CatalogueState &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isGeneratingMetadata, isGeneratingMetadata) ||
                other.isGeneratingMetadata == isGeneratingMetadata) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._suggestedCaptions, _suggestedCaptions) &&
            (identical(other.lastGeneratedKey, lastGeneratedKey) ||
                other.lastGeneratedKey == lastGeneratedKey) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSubmitting,
      isGeneratingMetadata,
      description,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_suggestedCaptions),
      lastGeneratedKey,
      errorMessage);

  @override
  String toString() {
    return 'CatalogueState(isSubmitting: $isSubmitting, isGeneratingMetadata: $isGeneratingMetadata, description: $description, tags: $tags, suggestedCaptions: $suggestedCaptions, lastGeneratedKey: $lastGeneratedKey, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$CatalogueStateCopyWith<$Res>
    implements $CatalogueStateCopyWith<$Res> {
  factory _$CatalogueStateCopyWith(
          _CatalogueState value, $Res Function(_CatalogueState) _then) =
      __$CatalogueStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isSubmitting,
      bool isGeneratingMetadata,
      String description,
      List<String> tags,
      List<String> suggestedCaptions,
      String? lastGeneratedKey,
      String? errorMessage});
}

/// @nodoc
class __$CatalogueStateCopyWithImpl<$Res>
    implements _$CatalogueStateCopyWith<$Res> {
  __$CatalogueStateCopyWithImpl(this._self, this._then);

  final _CatalogueState _self;
  final $Res Function(_CatalogueState) _then;

  /// Create a copy of CatalogueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isSubmitting = null,
    Object? isGeneratingMetadata = null,
    Object? description = null,
    Object? tags = null,
    Object? suggestedCaptions = null,
    Object? lastGeneratedKey = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_CatalogueState(
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isGeneratingMetadata: null == isGeneratingMetadata
          ? _self.isGeneratingMetadata
          : isGeneratingMetadata // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestedCaptions: null == suggestedCaptions
          ? _self._suggestedCaptions
          : suggestedCaptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastGeneratedKey: freezed == lastGeneratedKey
          ? _self.lastGeneratedKey
          : lastGeneratedKey // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
