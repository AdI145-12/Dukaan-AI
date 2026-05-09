// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'background_select_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackgroundSelectState {
  int? get selectedStyleIndex;
  String get customPrompt;
  bool get isGenerating;
  String? get error;
  GeneratedAd? get generatedAd;

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BackgroundSelectStateCopyWith<BackgroundSelectState> get copyWith =>
      _$BackgroundSelectStateCopyWithImpl<BackgroundSelectState>(
          this as BackgroundSelectState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackgroundSelectState &&
            (identical(other.selectedStyleIndex, selectedStyleIndex) ||
                other.selectedStyleIndex == selectedStyleIndex) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.generatedAd, generatedAd) ||
                other.generatedAd == generatedAd));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedStyleIndex, customPrompt,
      isGenerating, error, generatedAd);

  @override
  String toString() {
    return 'BackgroundSelectState(selectedStyleIndex: $selectedStyleIndex, customPrompt: $customPrompt, isGenerating: $isGenerating, error: $error, generatedAd: $generatedAd)';
  }
}

/// @nodoc
abstract mixin class $BackgroundSelectStateCopyWith<$Res> {
  factory $BackgroundSelectStateCopyWith(BackgroundSelectState value,
          $Res Function(BackgroundSelectState) _then) =
      _$BackgroundSelectStateCopyWithImpl;
  @useResult
  $Res call(
      {int? selectedStyleIndex,
      String customPrompt,
      bool isGenerating,
      String? error,
      GeneratedAd? generatedAd});

  $GeneratedAdCopyWith<$Res>? get generatedAd;
}

/// @nodoc
class _$BackgroundSelectStateCopyWithImpl<$Res>
    implements $BackgroundSelectStateCopyWith<$Res> {
  _$BackgroundSelectStateCopyWithImpl(this._self, this._then);

  final BackgroundSelectState _self;
  final $Res Function(BackgroundSelectState) _then;

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedStyleIndex = freezed,
    Object? customPrompt = null,
    Object? isGenerating = null,
    Object? error = freezed,
    Object? generatedAd = freezed,
  }) {
    return _then(_self.copyWith(
      selectedStyleIndex: freezed == selectedStyleIndex
          ? _self.selectedStyleIndex
          : selectedStyleIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      customPrompt: null == customPrompt
          ? _self.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      isGenerating: null == isGenerating
          ? _self.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      generatedAd: freezed == generatedAd
          ? _self.generatedAd
          : generatedAd // ignore: cast_nullable_to_non_nullable
              as GeneratedAd?,
    ));
  }

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeneratedAdCopyWith<$Res>? get generatedAd {
    if (_self.generatedAd == null) {
      return null;
    }

    return $GeneratedAdCopyWith<$Res>(_self.generatedAd!, (value) {
      return _then(_self.copyWith(generatedAd: value));
    });
  }
}

/// Adds pattern-matching-related methods to [BackgroundSelectState].
extension BackgroundSelectStatePatterns on BackgroundSelectState {
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
    TResult Function(_BackgroundSelectState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState() when $default != null:
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
    TResult Function(_BackgroundSelectState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState():
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
    TResult? Function(_BackgroundSelectState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState() when $default != null:
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
    TResult Function(int? selectedStyleIndex, String customPrompt,
            bool isGenerating, String? error, GeneratedAd? generatedAd)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState() when $default != null:
        return $default(_that.selectedStyleIndex, _that.customPrompt,
            _that.isGenerating, _that.error, _that.generatedAd);
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
    TResult Function(int? selectedStyleIndex, String customPrompt,
            bool isGenerating, String? error, GeneratedAd? generatedAd)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState():
        return $default(_that.selectedStyleIndex, _that.customPrompt,
            _that.isGenerating, _that.error, _that.generatedAd);
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
    TResult? Function(int? selectedStyleIndex, String customPrompt,
            bool isGenerating, String? error, GeneratedAd? generatedAd)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackgroundSelectState() when $default != null:
        return $default(_that.selectedStyleIndex, _that.customPrompt,
            _that.isGenerating, _that.error, _that.generatedAd);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BackgroundSelectState implements BackgroundSelectState {
  _BackgroundSelectState(
      {this.selectedStyleIndex,
      this.customPrompt = '',
      this.isGenerating = false,
      this.error,
      this.generatedAd});

  @override
  final int? selectedStyleIndex;
  @override
  @JsonKey()
  final String customPrompt;
  @override
  @JsonKey()
  final bool isGenerating;
  @override
  final String? error;
  @override
  final GeneratedAd? generatedAd;

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BackgroundSelectStateCopyWith<_BackgroundSelectState> get copyWith =>
      __$BackgroundSelectStateCopyWithImpl<_BackgroundSelectState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BackgroundSelectState &&
            (identical(other.selectedStyleIndex, selectedStyleIndex) ||
                other.selectedStyleIndex == selectedStyleIndex) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt) &&
            (identical(other.isGenerating, isGenerating) ||
                other.isGenerating == isGenerating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.generatedAd, generatedAd) ||
                other.generatedAd == generatedAd));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedStyleIndex, customPrompt,
      isGenerating, error, generatedAd);

  @override
  String toString() {
    return 'BackgroundSelectState(selectedStyleIndex: $selectedStyleIndex, customPrompt: $customPrompt, isGenerating: $isGenerating, error: $error, generatedAd: $generatedAd)';
  }
}

/// @nodoc
abstract mixin class _$BackgroundSelectStateCopyWith<$Res>
    implements $BackgroundSelectStateCopyWith<$Res> {
  factory _$BackgroundSelectStateCopyWith(_BackgroundSelectState value,
          $Res Function(_BackgroundSelectState) _then) =
      __$BackgroundSelectStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int? selectedStyleIndex,
      String customPrompt,
      bool isGenerating,
      String? error,
      GeneratedAd? generatedAd});

  @override
  $GeneratedAdCopyWith<$Res>? get generatedAd;
}

/// @nodoc
class __$BackgroundSelectStateCopyWithImpl<$Res>
    implements _$BackgroundSelectStateCopyWith<$Res> {
  __$BackgroundSelectStateCopyWithImpl(this._self, this._then);

  final _BackgroundSelectState _self;
  final $Res Function(_BackgroundSelectState) _then;

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? selectedStyleIndex = freezed,
    Object? customPrompt = null,
    Object? isGenerating = null,
    Object? error = freezed,
    Object? generatedAd = freezed,
  }) {
    return _then(_BackgroundSelectState(
      selectedStyleIndex: freezed == selectedStyleIndex
          ? _self.selectedStyleIndex
          : selectedStyleIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      customPrompt: null == customPrompt
          ? _self.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String,
      isGenerating: null == isGenerating
          ? _self.isGenerating
          : isGenerating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      generatedAd: freezed == generatedAd
          ? _self.generatedAd
          : generatedAd // ignore: cast_nullable_to_non_nullable
              as GeneratedAd?,
    ));
  }

  /// Create a copy of BackgroundSelectState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeneratedAdCopyWith<$Res>? get generatedAd {
    if (_self.generatedAd == null) {
      return null;
    }

    return $GeneratedAdCopyWith<$Res>(_self.generatedAd!, (value) {
      return _then(_self.copyWith(generatedAd: value));
    });
  }
}

// dart format on
