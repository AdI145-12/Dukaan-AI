// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_ad.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GeneratedAd {
  String get id;
  String get userId;
  String get imageUrl;
  String? get thumbnailUrl;
  String? get backgroundStyle;
  String? get captionHindi;
  String? get captionEnglish;
  int get shareCount;
  int get downloadCount;
  String? get festivalTag;
  DateTime get createdAt;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GeneratedAdCopyWith<GeneratedAd> get copyWith =>
      _$GeneratedAdCopyWithImpl<GeneratedAd>(this as GeneratedAd, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GeneratedAd &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.backgroundStyle, backgroundStyle) ||
                other.backgroundStyle == backgroundStyle) &&
            (identical(other.captionHindi, captionHindi) ||
                other.captionHindi == captionHindi) &&
            (identical(other.captionEnglish, captionEnglish) ||
                other.captionEnglish == captionEnglish) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.festivalTag, festivalTag) ||
                other.festivalTag == festivalTag) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      imageUrl,
      thumbnailUrl,
      backgroundStyle,
      captionHindi,
      captionEnglish,
      shareCount,
      downloadCount,
      festivalTag,
      createdAt);

  @override
  String toString() {
    return 'GeneratedAd(id: $id, userId: $userId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, backgroundStyle: $backgroundStyle, captionHindi: $captionHindi, captionEnglish: $captionEnglish, shareCount: $shareCount, downloadCount: $downloadCount, festivalTag: $festivalTag, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $GeneratedAdCopyWith<$Res> {
  factory $GeneratedAdCopyWith(
          GeneratedAd value, $Res Function(GeneratedAd) _then) =
      _$GeneratedAdCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String imageUrl,
      String? thumbnailUrl,
      String? backgroundStyle,
      String? captionHindi,
      String? captionEnglish,
      int shareCount,
      int downloadCount,
      String? festivalTag,
      DateTime createdAt});
}

/// @nodoc
class _$GeneratedAdCopyWithImpl<$Res> implements $GeneratedAdCopyWith<$Res> {
  _$GeneratedAdCopyWithImpl(this._self, this._then);

  final GeneratedAd _self;
  final $Res Function(GeneratedAd) _then;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? backgroundStyle = freezed,
    Object? captionHindi = freezed,
    Object? captionEnglish = freezed,
    Object? shareCount = null,
    Object? downloadCount = null,
    Object? festivalTag = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundStyle: freezed == backgroundStyle
          ? _self.backgroundStyle
          : backgroundStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      captionHindi: freezed == captionHindi
          ? _self.captionHindi
          : captionHindi // ignore: cast_nullable_to_non_nullable
              as String?,
      captionEnglish: freezed == captionEnglish
          ? _self.captionEnglish
          : captionEnglish // ignore: cast_nullable_to_non_nullable
              as String?,
      shareCount: null == shareCount
          ? _self.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      downloadCount: null == downloadCount
          ? _self.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      festivalTag: freezed == festivalTag
          ? _self.festivalTag
          : festivalTag // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [GeneratedAd].
extension GeneratedAdPatterns on GeneratedAd {
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
    TResult Function(_GeneratedAd value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd() when $default != null:
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
    TResult Function(_GeneratedAd value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd():
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
    TResult? Function(_GeneratedAd value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd() when $default != null:
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
            String id,
            String userId,
            String imageUrl,
            String? thumbnailUrl,
            String? backgroundStyle,
            String? captionHindi,
            String? captionEnglish,
            int shareCount,
            int downloadCount,
            String? festivalTag,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.backgroundStyle,
            _that.captionHindi,
            _that.captionEnglish,
            _that.shareCount,
            _that.downloadCount,
            _that.festivalTag,
            _that.createdAt);
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
            String id,
            String userId,
            String imageUrl,
            String? thumbnailUrl,
            String? backgroundStyle,
            String? captionHindi,
            String? captionEnglish,
            int shareCount,
            int downloadCount,
            String? festivalTag,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd():
        return $default(
            _that.id,
            _that.userId,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.backgroundStyle,
            _that.captionHindi,
            _that.captionEnglish,
            _that.shareCount,
            _that.downloadCount,
            _that.festivalTag,
            _that.createdAt);
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
            String id,
            String userId,
            String imageUrl,
            String? thumbnailUrl,
            String? backgroundStyle,
            String? captionHindi,
            String? captionEnglish,
            int shareCount,
            int downloadCount,
            String? festivalTag,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GeneratedAd() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.imageUrl,
            _that.thumbnailUrl,
            _that.backgroundStyle,
            _that.captionHindi,
            _that.captionEnglish,
            _that.shareCount,
            _that.downloadCount,
            _that.festivalTag,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _GeneratedAd implements GeneratedAd {
  const _GeneratedAd(
      {required this.id,
      required this.userId,
      required this.imageUrl,
      this.thumbnailUrl,
      this.backgroundStyle,
      this.captionHindi,
      this.captionEnglish,
      this.shareCount = 0,
      this.downloadCount = 0,
      this.festivalTag,
      required this.createdAt});

  @override
  final String id;
  @override
  final String userId;
  @override
  final String imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? backgroundStyle;
  @override
  final String? captionHindi;
  @override
  final String? captionEnglish;
  @override
  @JsonKey()
  final int shareCount;
  @override
  @JsonKey()
  final int downloadCount;
  @override
  final String? festivalTag;
  @override
  final DateTime createdAt;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GeneratedAdCopyWith<_GeneratedAd> get copyWith =>
      __$GeneratedAdCopyWithImpl<_GeneratedAd>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GeneratedAd &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.backgroundStyle, backgroundStyle) ||
                other.backgroundStyle == backgroundStyle) &&
            (identical(other.captionHindi, captionHindi) ||
                other.captionHindi == captionHindi) &&
            (identical(other.captionEnglish, captionEnglish) ||
                other.captionEnglish == captionEnglish) &&
            (identical(other.shareCount, shareCount) ||
                other.shareCount == shareCount) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.festivalTag, festivalTag) ||
                other.festivalTag == festivalTag) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      imageUrl,
      thumbnailUrl,
      backgroundStyle,
      captionHindi,
      captionEnglish,
      shareCount,
      downloadCount,
      festivalTag,
      createdAt);

  @override
  String toString() {
    return 'GeneratedAd(id: $id, userId: $userId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, backgroundStyle: $backgroundStyle, captionHindi: $captionHindi, captionEnglish: $captionEnglish, shareCount: $shareCount, downloadCount: $downloadCount, festivalTag: $festivalTag, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$GeneratedAdCopyWith<$Res>
    implements $GeneratedAdCopyWith<$Res> {
  factory _$GeneratedAdCopyWith(
          _GeneratedAd value, $Res Function(_GeneratedAd) _then) =
      __$GeneratedAdCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String imageUrl,
      String? thumbnailUrl,
      String? backgroundStyle,
      String? captionHindi,
      String? captionEnglish,
      int shareCount,
      int downloadCount,
      String? festivalTag,
      DateTime createdAt});
}

/// @nodoc
class __$GeneratedAdCopyWithImpl<$Res> implements _$GeneratedAdCopyWith<$Res> {
  __$GeneratedAdCopyWithImpl(this._self, this._then);

  final _GeneratedAd _self;
  final $Res Function(_GeneratedAd) _then;

  /// Create a copy of GeneratedAd
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = freezed,
    Object? backgroundStyle = freezed,
    Object? captionHindi = freezed,
    Object? captionEnglish = freezed,
    Object? shareCount = null,
    Object? downloadCount = null,
    Object? festivalTag = freezed,
    Object? createdAt = null,
  }) {
    return _then(_GeneratedAd(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundStyle: freezed == backgroundStyle
          ? _self.backgroundStyle
          : backgroundStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      captionHindi: freezed == captionHindi
          ? _self.captionHindi
          : captionHindi // ignore: cast_nullable_to_non_nullable
              as String?,
      captionEnglish: freezed == captionEnglish
          ? _self.captionEnglish
          : captionEnglish // ignore: cast_nullable_to_non_nullable
              as String?,
      shareCount: null == shareCount
          ? _self.shareCount
          : shareCount // ignore: cast_nullable_to_non_nullable
              as int,
      downloadCount: null == downloadCount
          ? _self.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      festivalTag: freezed == festivalTag
          ? _self.festivalTag
          : festivalTag // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
