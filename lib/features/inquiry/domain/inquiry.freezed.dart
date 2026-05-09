// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inquiry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inquiry {
  String get id;
  String get userId;
  String get customerName;
  String? get customerPhone;
  String? get productId;
  String get productAsked;
  InquirySource get source;
  InquiryStatus get status;
  String? get notes;
  DateTime? get lastFollowUp;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InquiryCopyWith<Inquiry> get copyWith =>
      _$InquiryCopyWithImpl<Inquiry>(this as Inquiry, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Inquiry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productAsked, productAsked) ||
                other.productAsked == productAsked) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lastFollowUp, lastFollowUp) ||
                other.lastFollowUp == lastFollowUp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      customerName,
      customerPhone,
      productId,
      productAsked,
      source,
      status,
      notes,
      lastFollowUp,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Inquiry(id: $id, userId: $userId, customerName: $customerName, customerPhone: $customerPhone, productId: $productId, productAsked: $productAsked, source: $source, status: $status, notes: $notes, lastFollowUp: $lastFollowUp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $InquiryCopyWith<$Res> {
  factory $InquiryCopyWith(Inquiry value, $Res Function(Inquiry) _then) =
      _$InquiryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String customerName,
      String? customerPhone,
      String? productId,
      String productAsked,
      InquirySource source,
      InquiryStatus status,
      String? notes,
      DateTime? lastFollowUp,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$InquiryCopyWithImpl<$Res> implements $InquiryCopyWith<$Res> {
  _$InquiryCopyWithImpl(this._self, this._then);

  final Inquiry _self;
  final $Res Function(Inquiry) _then;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? productId = freezed,
    Object? productAsked = null,
    Object? source = null,
    Object? status = null,
    Object? notes = freezed,
    Object? lastFollowUp = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productAsked: null == productAsked
          ? _self.productAsked
          : productAsked // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as InquirySource,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InquiryStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFollowUp: freezed == lastFollowUp
          ? _self.lastFollowUp
          : lastFollowUp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Inquiry].
extension InquiryPatterns on Inquiry {
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
    TResult Function(_Inquiry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Inquiry() when $default != null:
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
    TResult Function(_Inquiry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Inquiry():
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
    TResult? Function(_Inquiry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Inquiry() when $default != null:
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
            String customerName,
            String? customerPhone,
            String? productId,
            String productAsked,
            InquirySource source,
            InquiryStatus status,
            String? notes,
            DateTime? lastFollowUp,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Inquiry() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.customerName,
            _that.customerPhone,
            _that.productId,
            _that.productAsked,
            _that.source,
            _that.status,
            _that.notes,
            _that.lastFollowUp,
            _that.createdAt,
            _that.updatedAt);
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
            String customerName,
            String? customerPhone,
            String? productId,
            String productAsked,
            InquirySource source,
            InquiryStatus status,
            String? notes,
            DateTime? lastFollowUp,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Inquiry():
        return $default(
            _that.id,
            _that.userId,
            _that.customerName,
            _that.customerPhone,
            _that.productId,
            _that.productAsked,
            _that.source,
            _that.status,
            _that.notes,
            _that.lastFollowUp,
            _that.createdAt,
            _that.updatedAt);
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
            String customerName,
            String? customerPhone,
            String? productId,
            String productAsked,
            InquirySource source,
            InquiryStatus status,
            String? notes,
            DateTime? lastFollowUp,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Inquiry() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.customerName,
            _that.customerPhone,
            _that.productId,
            _that.productAsked,
            _that.source,
            _that.status,
            _that.notes,
            _that.lastFollowUp,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Inquiry extends Inquiry {
  const _Inquiry(
      {required this.id,
      required this.userId,
      required this.customerName,
      this.customerPhone,
      this.productId,
      required this.productAsked,
      required this.source,
      required this.status,
      this.notes,
      this.lastFollowUp,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final String customerName;
  @override
  final String? customerPhone;
  @override
  final String? productId;
  @override
  final String productAsked;
  @override
  final InquirySource source;
  @override
  final InquiryStatus status;
  @override
  final String? notes;
  @override
  final DateTime? lastFollowUp;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InquiryCopyWith<_Inquiry> get copyWith =>
      __$InquiryCopyWithImpl<_Inquiry>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Inquiry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productAsked, productAsked) ||
                other.productAsked == productAsked) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lastFollowUp, lastFollowUp) ||
                other.lastFollowUp == lastFollowUp) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      customerName,
      customerPhone,
      productId,
      productAsked,
      source,
      status,
      notes,
      lastFollowUp,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Inquiry(id: $id, userId: $userId, customerName: $customerName, customerPhone: $customerPhone, productId: $productId, productAsked: $productAsked, source: $source, status: $status, notes: $notes, lastFollowUp: $lastFollowUp, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$InquiryCopyWith<$Res> implements $InquiryCopyWith<$Res> {
  factory _$InquiryCopyWith(_Inquiry value, $Res Function(_Inquiry) _then) =
      __$InquiryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String customerName,
      String? customerPhone,
      String? productId,
      String productAsked,
      InquirySource source,
      InquiryStatus status,
      String? notes,
      DateTime? lastFollowUp,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$InquiryCopyWithImpl<$Res> implements _$InquiryCopyWith<$Res> {
  __$InquiryCopyWithImpl(this._self, this._then);

  final _Inquiry _self;
  final $Res Function(_Inquiry) _then;

  /// Create a copy of Inquiry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? productId = freezed,
    Object? productAsked = null,
    Object? source = null,
    Object? status = null,
    Object? notes = freezed,
    Object? lastFollowUp = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_Inquiry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      productId: freezed == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productAsked: null == productAsked
          ? _self.productAsked
          : productAsked // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _self.source
          : source // ignore: cast_nullable_to_non_nullable
              as InquirySource,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InquiryStatus,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFollowUp: freezed == lastFollowUp
          ? _self.lastFollowUp
          : lastFollowUp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
