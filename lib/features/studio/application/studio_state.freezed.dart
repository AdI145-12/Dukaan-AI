// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'studio_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudioState {
  List<GeneratedAd> get recentAds;
  UserProfile? get profile;
  String? get todayFestival;

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StudioStateCopyWith<StudioState> get copyWith =>
      _$StudioStateCopyWithImpl<StudioState>(this as StudioState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StudioState &&
            const DeepCollectionEquality().equals(other.recentAds, recentAds) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.todayFestival, todayFestival) ||
                other.todayFestival == todayFestival));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(recentAds), profile, todayFestival);

  @override
  String toString() {
    return 'StudioState(recentAds: $recentAds, profile: $profile, todayFestival: $todayFestival)';
  }
}

/// @nodoc
abstract mixin class $StudioStateCopyWith<$Res> {
  factory $StudioStateCopyWith(
          StudioState value, $Res Function(StudioState) _then) =
      _$StudioStateCopyWithImpl;
  @useResult
  $Res call(
      {List<GeneratedAd> recentAds,
      UserProfile? profile,
      String? todayFestival});

  $UserProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class _$StudioStateCopyWithImpl<$Res> implements $StudioStateCopyWith<$Res> {
  _$StudioStateCopyWithImpl(this._self, this._then);

  final StudioState _self;
  final $Res Function(StudioState) _then;

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recentAds = null,
    Object? profile = freezed,
    Object? todayFestival = freezed,
  }) {
    return _then(_self.copyWith(
      recentAds: null == recentAds
          ? _self.recentAds
          : recentAds // ignore: cast_nullable_to_non_nullable
              as List<GeneratedAd>,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      todayFestival: freezed == todayFestival
          ? _self.todayFestival
          : todayFestival // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
      return _then(_self.copyWith(profile: value));
    });
  }
}

/// Adds pattern-matching-related methods to [StudioState].
extension StudioStatePatterns on StudioState {
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
    TResult Function(_StudioState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StudioState() when $default != null:
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
    TResult Function(_StudioState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StudioState():
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
    TResult? Function(_StudioState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StudioState() when $default != null:
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
    TResult Function(List<GeneratedAd> recentAds, UserProfile? profile,
            String? todayFestival)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StudioState() when $default != null:
        return $default(_that.recentAds, _that.profile, _that.todayFestival);
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
    TResult Function(List<GeneratedAd> recentAds, UserProfile? profile,
            String? todayFestival)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StudioState():
        return $default(_that.recentAds, _that.profile, _that.todayFestival);
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
    TResult? Function(List<GeneratedAd> recentAds, UserProfile? profile,
            String? todayFestival)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StudioState() when $default != null:
        return $default(_that.recentAds, _that.profile, _that.todayFestival);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _StudioState implements StudioState {
  const _StudioState(
      {final List<GeneratedAd> recentAds = const <GeneratedAd>[],
      this.profile,
      this.todayFestival})
      : _recentAds = recentAds;

  final List<GeneratedAd> _recentAds;
  @override
  @JsonKey()
  List<GeneratedAd> get recentAds {
    if (_recentAds is EqualUnmodifiableListView) return _recentAds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAds);
  }

  @override
  final UserProfile? profile;
  @override
  final String? todayFestival;

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StudioStateCopyWith<_StudioState> get copyWith =>
      __$StudioStateCopyWithImpl<_StudioState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StudioState &&
            const DeepCollectionEquality()
                .equals(other._recentAds, _recentAds) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.todayFestival, todayFestival) ||
                other.todayFestival == todayFestival));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_recentAds), profile, todayFestival);

  @override
  String toString() {
    return 'StudioState(recentAds: $recentAds, profile: $profile, todayFestival: $todayFestival)';
  }
}

/// @nodoc
abstract mixin class _$StudioStateCopyWith<$Res>
    implements $StudioStateCopyWith<$Res> {
  factory _$StudioStateCopyWith(
          _StudioState value, $Res Function(_StudioState) _then) =
      __$StudioStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<GeneratedAd> recentAds,
      UserProfile? profile,
      String? todayFestival});

  @override
  $UserProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class __$StudioStateCopyWithImpl<$Res> implements _$StudioStateCopyWith<$Res> {
  __$StudioStateCopyWithImpl(this._self, this._then);

  final _StudioState _self;
  final $Res Function(_StudioState) _then;

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? recentAds = null,
    Object? profile = freezed,
    Object? todayFestival = freezed,
  }) {
    return _then(_StudioState(
      recentAds: null == recentAds
          ? _self._recentAds
          : recentAds // ignore: cast_nullable_to_non_nullable
              as List<GeneratedAd>,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      todayFestival: freezed == todayFestival
          ? _self.todayFestival
          : todayFestival // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of StudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_self.profile!, (value) {
      return _then(_self.copyWith(profile: value));
    });
  }
}

// dart format on
