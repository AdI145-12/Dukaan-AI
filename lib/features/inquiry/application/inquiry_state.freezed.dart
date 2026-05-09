// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inquiry_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InquiryState {
  List<Inquiry> get inquiries;
  InquiryStatus? get activeFilter;

  /// Create a copy of InquiryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InquiryStateCopyWith<InquiryState> get copyWith =>
      _$InquiryStateCopyWithImpl<InquiryState>(
          this as InquiryState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InquiryState &&
            const DeepCollectionEquality().equals(other.inquiries, inquiries) &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(inquiries), activeFilter);

  @override
  String toString() {
    return 'InquiryState(inquiries: $inquiries, activeFilter: $activeFilter)';
  }
}

/// @nodoc
abstract mixin class $InquiryStateCopyWith<$Res> {
  factory $InquiryStateCopyWith(
          InquiryState value, $Res Function(InquiryState) _then) =
      _$InquiryStateCopyWithImpl;
  @useResult
  $Res call({List<Inquiry> inquiries, InquiryStatus? activeFilter});
}

/// @nodoc
class _$InquiryStateCopyWithImpl<$Res> implements $InquiryStateCopyWith<$Res> {
  _$InquiryStateCopyWithImpl(this._self, this._then);

  final InquiryState _self;
  final $Res Function(InquiryState) _then;

  /// Create a copy of InquiryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inquiries = null,
    Object? activeFilter = freezed,
  }) {
    return _then(_self.copyWith(
      inquiries: null == inquiries
          ? _self.inquiries
          : inquiries // ignore: cast_nullable_to_non_nullable
              as List<Inquiry>,
      activeFilter: freezed == activeFilter
          ? _self.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as InquiryStatus?,
    ));
  }
}

/// Adds pattern-matching-related methods to [InquiryState].
extension InquiryStatePatterns on InquiryState {
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
    TResult Function(_InquiryState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InquiryState() when $default != null:
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
    TResult Function(_InquiryState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InquiryState():
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
    TResult? Function(_InquiryState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InquiryState() when $default != null:
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
    TResult Function(List<Inquiry> inquiries, InquiryStatus? activeFilter)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InquiryState() when $default != null:
        return $default(_that.inquiries, _that.activeFilter);
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
    TResult Function(List<Inquiry> inquiries, InquiryStatus? activeFilter)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InquiryState():
        return $default(_that.inquiries, _that.activeFilter);
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
    TResult? Function(List<Inquiry> inquiries, InquiryStatus? activeFilter)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InquiryState() when $default != null:
        return $default(_that.inquiries, _that.activeFilter);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InquiryState extends InquiryState {
  const _InquiryState(
      {final List<Inquiry> inquiries = const <Inquiry>[], this.activeFilter})
      : _inquiries = inquiries,
        super._();

  final List<Inquiry> _inquiries;
  @override
  @JsonKey()
  List<Inquiry> get inquiries {
    if (_inquiries is EqualUnmodifiableListView) return _inquiries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inquiries);
  }

  @override
  final InquiryStatus? activeFilter;

  /// Create a copy of InquiryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InquiryStateCopyWith<_InquiryState> get copyWith =>
      __$InquiryStateCopyWithImpl<_InquiryState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InquiryState &&
            const DeepCollectionEquality()
                .equals(other._inquiries, _inquiries) &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_inquiries), activeFilter);

  @override
  String toString() {
    return 'InquiryState(inquiries: $inquiries, activeFilter: $activeFilter)';
  }
}

/// @nodoc
abstract mixin class _$InquiryStateCopyWith<$Res>
    implements $InquiryStateCopyWith<$Res> {
  factory _$InquiryStateCopyWith(
          _InquiryState value, $Res Function(_InquiryState) _then) =
      __$InquiryStateCopyWithImpl;
  @override
  @useResult
  $Res call({List<Inquiry> inquiries, InquiryStatus? activeFilter});
}

/// @nodoc
class __$InquiryStateCopyWithImpl<$Res>
    implements _$InquiryStateCopyWith<$Res> {
  __$InquiryStateCopyWithImpl(this._self, this._then);

  final _InquiryState _self;
  final $Res Function(_InquiryState) _then;

  /// Create a copy of InquiryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? inquiries = null,
    Object? activeFilter = freezed,
  }) {
    return _then(_InquiryState(
      inquiries: null == inquiries
          ? _self._inquiries
          : inquiries // ignore: cast_nullable_to_non_nullable
              as List<Inquiry>,
      activeFilter: freezed == activeFilter
          ? _self.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as InquiryStatus?,
    ));
  }
}

// dart format on
