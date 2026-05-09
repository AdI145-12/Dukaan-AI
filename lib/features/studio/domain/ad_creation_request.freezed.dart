// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ad_creation_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdCreationRequest {
  String get processedImageBase64;
  String get backgroundStyleId;
  String get userId;
  String? get customPrompt;

  /// Create a copy of AdCreationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AdCreationRequestCopyWith<AdCreationRequest> get copyWith =>
      _$AdCreationRequestCopyWithImpl<AdCreationRequest>(
          this as AdCreationRequest, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AdCreationRequest &&
            (identical(other.processedImageBase64, processedImageBase64) ||
                other.processedImageBase64 == processedImageBase64) &&
            (identical(other.backgroundStyleId, backgroundStyleId) ||
                other.backgroundStyleId == backgroundStyleId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, processedImageBase64,
      backgroundStyleId, userId, customPrompt);

  @override
  String toString() {
    return 'AdCreationRequest(processedImageBase64: $processedImageBase64, backgroundStyleId: $backgroundStyleId, userId: $userId, customPrompt: $customPrompt)';
  }
}

/// @nodoc
abstract mixin class $AdCreationRequestCopyWith<$Res> {
  factory $AdCreationRequestCopyWith(
          AdCreationRequest value, $Res Function(AdCreationRequest) _then) =
      _$AdCreationRequestCopyWithImpl;
  @useResult
  $Res call(
      {String processedImageBase64,
      String backgroundStyleId,
      String userId,
      String? customPrompt});
}

/// @nodoc
class _$AdCreationRequestCopyWithImpl<$Res>
    implements $AdCreationRequestCopyWith<$Res> {
  _$AdCreationRequestCopyWithImpl(this._self, this._then);

  final AdCreationRequest _self;
  final $Res Function(AdCreationRequest) _then;

  /// Create a copy of AdCreationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processedImageBase64 = null,
    Object? backgroundStyleId = null,
    Object? userId = null,
    Object? customPrompt = freezed,
  }) {
    return _then(_self.copyWith(
      processedImageBase64: null == processedImageBase64
          ? _self.processedImageBase64
          : processedImageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundStyleId: null == backgroundStyleId
          ? _self.backgroundStyleId
          : backgroundStyleId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      customPrompt: freezed == customPrompt
          ? _self.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AdCreationRequest].
extension AdCreationRequestPatterns on AdCreationRequest {
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
    TResult Function(_AdCreationRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest() when $default != null:
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
    TResult Function(_AdCreationRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest():
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
    TResult? Function(_AdCreationRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest() when $default != null:
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
    TResult Function(String processedImageBase64, String backgroundStyleId,
            String userId, String? customPrompt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest() when $default != null:
        return $default(_that.processedImageBase64, _that.backgroundStyleId,
            _that.userId, _that.customPrompt);
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
    TResult Function(String processedImageBase64, String backgroundStyleId,
            String userId, String? customPrompt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest():
        return $default(_that.processedImageBase64, _that.backgroundStyleId,
            _that.userId, _that.customPrompt);
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
    TResult? Function(String processedImageBase64, String backgroundStyleId,
            String userId, String? customPrompt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AdCreationRequest() when $default != null:
        return $default(_that.processedImageBase64, _that.backgroundStyleId,
            _that.userId, _that.customPrompt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AdCreationRequest implements AdCreationRequest {
  const _AdCreationRequest(
      {required this.processedImageBase64,
      required this.backgroundStyleId,
      required this.userId,
      this.customPrompt});

  @override
  final String processedImageBase64;
  @override
  final String backgroundStyleId;
  @override
  final String userId;
  @override
  final String? customPrompt;

  /// Create a copy of AdCreationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AdCreationRequestCopyWith<_AdCreationRequest> get copyWith =>
      __$AdCreationRequestCopyWithImpl<_AdCreationRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AdCreationRequest &&
            (identical(other.processedImageBase64, processedImageBase64) ||
                other.processedImageBase64 == processedImageBase64) &&
            (identical(other.backgroundStyleId, backgroundStyleId) ||
                other.backgroundStyleId == backgroundStyleId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customPrompt, customPrompt) ||
                other.customPrompt == customPrompt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, processedImageBase64,
      backgroundStyleId, userId, customPrompt);

  @override
  String toString() {
    return 'AdCreationRequest(processedImageBase64: $processedImageBase64, backgroundStyleId: $backgroundStyleId, userId: $userId, customPrompt: $customPrompt)';
  }
}

/// @nodoc
abstract mixin class _$AdCreationRequestCopyWith<$Res>
    implements $AdCreationRequestCopyWith<$Res> {
  factory _$AdCreationRequestCopyWith(
          _AdCreationRequest value, $Res Function(_AdCreationRequest) _then) =
      __$AdCreationRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String processedImageBase64,
      String backgroundStyleId,
      String userId,
      String? customPrompt});
}

/// @nodoc
class __$AdCreationRequestCopyWithImpl<$Res>
    implements _$AdCreationRequestCopyWith<$Res> {
  __$AdCreationRequestCopyWithImpl(this._self, this._then);

  final _AdCreationRequest _self;
  final $Res Function(_AdCreationRequest) _then;

  /// Create a copy of AdCreationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? processedImageBase64 = null,
    Object? backgroundStyleId = null,
    Object? userId = null,
    Object? customPrompt = freezed,
  }) {
    return _then(_AdCreationRequest(
      processedImageBase64: null == processedImageBase64
          ? _self.processedImageBase64
          : processedImageBase64 // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundStyleId: null == backgroundStyleId
          ? _self.backgroundStyleId
          : backgroundStyleId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      customPrompt: freezed == customPrompt
          ? _self.customPrompt
          : customPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
