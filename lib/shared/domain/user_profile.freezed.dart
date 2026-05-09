// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {
  String get id;
  String get shopName;
  String? get ownerName;
  String? get phone;
  String? get city;
  String? get category;
  String get tier;
  int get creditsRemaining;
  String get language;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<UserProfile> get copyWith =>
      _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.creditsRemaining, creditsRemaining) ||
                other.creditsRemaining == creditsRemaining) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, shopName, ownerName, phone,
      city, category, tier, creditsRemaining, language);

  @override
  String toString() {
    return 'UserProfile(id: $id, shopName: $shopName, ownerName: $ownerName, phone: $phone, city: $city, category: $category, tier: $tier, creditsRemaining: $creditsRemaining, language: $language)';
  }
}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) _then) =
      _$UserProfileCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String shopName,
      String? ownerName,
      String? phone,
      String? city,
      String? category,
      String tier,
      int creditsRemaining,
      String language});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res> implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shopName = null,
    Object? ownerName = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? category = freezed,
    Object? tier = null,
    Object? creditsRemaining = null,
    Object? language = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shopName: null == shopName
          ? _self.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerName: freezed == ownerName
          ? _self.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _self.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      creditsRemaining: null == creditsRemaining
          ? _self.creditsRemaining
          : creditsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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
    TResult Function(_UserProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
    TResult Function(_UserProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
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
    TResult? Function(_UserProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
            String shopName,
            String? ownerName,
            String? phone,
            String? city,
            String? category,
            String tier,
            int creditsRemaining,
            String language)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(
            _that.id,
            _that.shopName,
            _that.ownerName,
            _that.phone,
            _that.city,
            _that.category,
            _that.tier,
            _that.creditsRemaining,
            _that.language);
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
            String shopName,
            String? ownerName,
            String? phone,
            String? city,
            String? category,
            String tier,
            int creditsRemaining,
            String language)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
        return $default(
            _that.id,
            _that.shopName,
            _that.ownerName,
            _that.phone,
            _that.city,
            _that.category,
            _that.tier,
            _that.creditsRemaining,
            _that.language);
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
            String shopName,
            String? ownerName,
            String? phone,
            String? city,
            String? category,
            String tier,
            int creditsRemaining,
            String language)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(
            _that.id,
            _that.shopName,
            _that.ownerName,
            _that.phone,
            _that.city,
            _that.category,
            _that.tier,
            _that.creditsRemaining,
            _that.language);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UserProfile implements UserProfile {
  const _UserProfile(
      {required this.id,
      required this.shopName,
      this.ownerName,
      this.phone,
      this.city,
      this.category,
      this.tier = 'free',
      this.creditsRemaining = 3,
      this.language = 'hinglish'});

  @override
  final String id;
  @override
  final String shopName;
  @override
  final String? ownerName;
  @override
  final String? phone;
  @override
  final String? city;
  @override
  final String? category;
  @override
  @JsonKey()
  final String tier;
  @override
  @JsonKey()
  final int creditsRemaining;
  @override
  @JsonKey()
  final String language;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserProfileCopyWith<_UserProfile> get copyWith =>
      __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.creditsRemaining, creditsRemaining) ||
                other.creditsRemaining == creditsRemaining) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, shopName, ownerName, phone,
      city, category, tier, creditsRemaining, language);

  @override
  String toString() {
    return 'UserProfile(id: $id, shopName: $shopName, ownerName: $ownerName, phone: $phone, city: $city, category: $category, tier: $tier, creditsRemaining: $creditsRemaining, language: $language)';
  }
}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(
          _UserProfile value, $Res Function(_UserProfile) _then) =
      __$UserProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String shopName,
      String? ownerName,
      String? phone,
      String? city,
      String? category,
      String tier,
      int creditsRemaining,
      String language});
}

/// @nodoc
class __$UserProfileCopyWithImpl<$Res> implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? shopName = null,
    Object? ownerName = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? category = freezed,
    Object? tier = null,
    Object? creditsRemaining = null,
    Object? language = null,
  }) {
    return _then(_UserProfile(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shopName: null == shopName
          ? _self.shopName
          : shopName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerName: freezed == ownerName
          ? _self.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      tier: null == tier
          ? _self.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      creditsRemaining: null == creditsRemaining
          ? _self.creditsRemaining
          : creditsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
