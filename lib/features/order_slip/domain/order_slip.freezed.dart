// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_slip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderSlip {
  String get id;
  String get userId;
  String? get inquiryId;
  String get slipNumber;
  String get customerName;
  String? get customerPhone;
  List<OrderLineItem> get lineItems;
  double get subtotal;
  double get discountAmount;
  double get deliveryCharge;
  double get total;
  PaymentMode get paymentMode;
  String? get upiId;
  String? get deliveryNote;
  DateTime? get expectedDeliveryDate;
  String? get slipImageUrl;
  bool get gstEnabled;
  DateTime get createdAt;

  /// Create a copy of OrderSlip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderSlipCopyWith<OrderSlip> get copyWith =>
      _$OrderSlipCopyWithImpl<OrderSlip>(this as OrderSlip, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderSlip &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.inquiryId, inquiryId) ||
                other.inquiryId == inquiryId) &&
            (identical(other.slipNumber, slipNumber) ||
                other.slipNumber == slipNumber) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            const DeepCollectionEquality().equals(other.lineItems, lineItems) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.deliveryCharge, deliveryCharge) ||
                other.deliveryCharge == deliveryCharge) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.deliveryNote, deliveryNote) ||
                other.deliveryNote == deliveryNote) &&
            (identical(other.expectedDeliveryDate, expectedDeliveryDate) ||
                other.expectedDeliveryDate == expectedDeliveryDate) &&
            (identical(other.slipImageUrl, slipImageUrl) ||
                other.slipImageUrl == slipImageUrl) &&
            (identical(other.gstEnabled, gstEnabled) ||
                other.gstEnabled == gstEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      inquiryId,
      slipNumber,
      customerName,
      customerPhone,
      const DeepCollectionEquality().hash(lineItems),
      subtotal,
      discountAmount,
      deliveryCharge,
      total,
      paymentMode,
      upiId,
      deliveryNote,
      expectedDeliveryDate,
      slipImageUrl,
      gstEnabled,
      createdAt);

  @override
  String toString() {
    return 'OrderSlip(id: $id, userId: $userId, inquiryId: $inquiryId, slipNumber: $slipNumber, customerName: $customerName, customerPhone: $customerPhone, lineItems: $lineItems, subtotal: $subtotal, discountAmount: $discountAmount, deliveryCharge: $deliveryCharge, total: $total, paymentMode: $paymentMode, upiId: $upiId, deliveryNote: $deliveryNote, expectedDeliveryDate: $expectedDeliveryDate, slipImageUrl: $slipImageUrl, gstEnabled: $gstEnabled, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $OrderSlipCopyWith<$Res> {
  factory $OrderSlipCopyWith(OrderSlip value, $Res Function(OrderSlip) _then) =
      _$OrderSlipCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? inquiryId,
      String slipNumber,
      String customerName,
      String? customerPhone,
      List<OrderLineItem> lineItems,
      double subtotal,
      double discountAmount,
      double deliveryCharge,
      double total,
      PaymentMode paymentMode,
      String? upiId,
      String? deliveryNote,
      DateTime? expectedDeliveryDate,
      String? slipImageUrl,
      bool gstEnabled,
      DateTime createdAt});
}

/// @nodoc
class _$OrderSlipCopyWithImpl<$Res> implements $OrderSlipCopyWith<$Res> {
  _$OrderSlipCopyWithImpl(this._self, this._then);

  final OrderSlip _self;
  final $Res Function(OrderSlip) _then;

  /// Create a copy of OrderSlip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? inquiryId = freezed,
    Object? slipNumber = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? lineItems = null,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? deliveryCharge = null,
    Object? total = null,
    Object? paymentMode = null,
    Object? upiId = freezed,
    Object? deliveryNote = freezed,
    Object? expectedDeliveryDate = freezed,
    Object? slipImageUrl = freezed,
    Object? gstEnabled = null,
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
      inquiryId: freezed == inquiryId
          ? _self.inquiryId
          : inquiryId // ignore: cast_nullable_to_non_nullable
              as String?,
      slipNumber: null == slipNumber
          ? _self.slipNumber
          : slipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      lineItems: null == lineItems
          ? _self.lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<OrderLineItem>,
      subtotal: null == subtotal
          ? _self.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _self.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryCharge: null == deliveryCharge
          ? _self.deliveryCharge
          : deliveryCharge // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMode: null == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as PaymentMode,
      upiId: freezed == upiId
          ? _self.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryNote: freezed == deliveryNote
          ? _self.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedDeliveryDate: freezed == expectedDeliveryDate
          ? _self.expectedDeliveryDate
          : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      slipImageUrl: freezed == slipImageUrl
          ? _self.slipImageUrl
          : slipImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gstEnabled: null == gstEnabled
          ? _self.gstEnabled
          : gstEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [OrderSlip].
extension OrderSlipPatterns on OrderSlip {
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
    TResult Function(_OrderSlip value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSlip() when $default != null:
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
    TResult Function(_OrderSlip value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlip():
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
    TResult? Function(_OrderSlip value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlip() when $default != null:
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
            String? inquiryId,
            String slipNumber,
            String customerName,
            String? customerPhone,
            List<OrderLineItem> lineItems,
            double subtotal,
            double discountAmount,
            double deliveryCharge,
            double total,
            PaymentMode paymentMode,
            String? upiId,
            String? deliveryNote,
            DateTime? expectedDeliveryDate,
            String? slipImageUrl,
            bool gstEnabled,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSlip() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.inquiryId,
            _that.slipNumber,
            _that.customerName,
            _that.customerPhone,
            _that.lineItems,
            _that.subtotal,
            _that.discountAmount,
            _that.deliveryCharge,
            _that.total,
            _that.paymentMode,
            _that.upiId,
            _that.deliveryNote,
            _that.expectedDeliveryDate,
            _that.slipImageUrl,
            _that.gstEnabled,
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
            String? inquiryId,
            String slipNumber,
            String customerName,
            String? customerPhone,
            List<OrderLineItem> lineItems,
            double subtotal,
            double discountAmount,
            double deliveryCharge,
            double total,
            PaymentMode paymentMode,
            String? upiId,
            String? deliveryNote,
            DateTime? expectedDeliveryDate,
            String? slipImageUrl,
            bool gstEnabled,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlip():
        return $default(
            _that.id,
            _that.userId,
            _that.inquiryId,
            _that.slipNumber,
            _that.customerName,
            _that.customerPhone,
            _that.lineItems,
            _that.subtotal,
            _that.discountAmount,
            _that.deliveryCharge,
            _that.total,
            _that.paymentMode,
            _that.upiId,
            _that.deliveryNote,
            _that.expectedDeliveryDate,
            _that.slipImageUrl,
            _that.gstEnabled,
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
            String? inquiryId,
            String slipNumber,
            String customerName,
            String? customerPhone,
            List<OrderLineItem> lineItems,
            double subtotal,
            double discountAmount,
            double deliveryCharge,
            double total,
            PaymentMode paymentMode,
            String? upiId,
            String? deliveryNote,
            DateTime? expectedDeliveryDate,
            String? slipImageUrl,
            bool gstEnabled,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlip() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.inquiryId,
            _that.slipNumber,
            _that.customerName,
            _that.customerPhone,
            _that.lineItems,
            _that.subtotal,
            _that.discountAmount,
            _that.deliveryCharge,
            _that.total,
            _that.paymentMode,
            _that.upiId,
            _that.deliveryNote,
            _that.expectedDeliveryDate,
            _that.slipImageUrl,
            _that.gstEnabled,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OrderSlip extends OrderSlip {
  const _OrderSlip(
      {required this.id,
      required this.userId,
      this.inquiryId,
      required this.slipNumber,
      required this.customerName,
      this.customerPhone,
      required final List<OrderLineItem> lineItems,
      required this.subtotal,
      this.discountAmount = 0,
      this.deliveryCharge = 0,
      required this.total,
      this.paymentMode = PaymentMode.pending,
      this.upiId,
      this.deliveryNote,
      this.expectedDeliveryDate,
      this.slipImageUrl,
      this.gstEnabled = false,
      required this.createdAt})
      : _lineItems = lineItems,
        super._();

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? inquiryId;
  @override
  final String slipNumber;
  @override
  final String customerName;
  @override
  final String? customerPhone;
  final List<OrderLineItem> _lineItems;
  @override
  List<OrderLineItem> get lineItems {
    if (_lineItems is EqualUnmodifiableListView) return _lineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineItems);
  }

  @override
  final double subtotal;
  @override
  @JsonKey()
  final double discountAmount;
  @override
  @JsonKey()
  final double deliveryCharge;
  @override
  final double total;
  @override
  @JsonKey()
  final PaymentMode paymentMode;
  @override
  final String? upiId;
  @override
  final String? deliveryNote;
  @override
  final DateTime? expectedDeliveryDate;
  @override
  final String? slipImageUrl;
  @override
  @JsonKey()
  final bool gstEnabled;
  @override
  final DateTime createdAt;

  /// Create a copy of OrderSlip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderSlipCopyWith<_OrderSlip> get copyWith =>
      __$OrderSlipCopyWithImpl<_OrderSlip>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderSlip &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.inquiryId, inquiryId) ||
                other.inquiryId == inquiryId) &&
            (identical(other.slipNumber, slipNumber) ||
                other.slipNumber == slipNumber) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            const DeepCollectionEquality()
                .equals(other._lineItems, _lineItems) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.deliveryCharge, deliveryCharge) ||
                other.deliveryCharge == deliveryCharge) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.paymentMode, paymentMode) ||
                other.paymentMode == paymentMode) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.deliveryNote, deliveryNote) ||
                other.deliveryNote == deliveryNote) &&
            (identical(other.expectedDeliveryDate, expectedDeliveryDate) ||
                other.expectedDeliveryDate == expectedDeliveryDate) &&
            (identical(other.slipImageUrl, slipImageUrl) ||
                other.slipImageUrl == slipImageUrl) &&
            (identical(other.gstEnabled, gstEnabled) ||
                other.gstEnabled == gstEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      inquiryId,
      slipNumber,
      customerName,
      customerPhone,
      const DeepCollectionEquality().hash(_lineItems),
      subtotal,
      discountAmount,
      deliveryCharge,
      total,
      paymentMode,
      upiId,
      deliveryNote,
      expectedDeliveryDate,
      slipImageUrl,
      gstEnabled,
      createdAt);

  @override
  String toString() {
    return 'OrderSlip(id: $id, userId: $userId, inquiryId: $inquiryId, slipNumber: $slipNumber, customerName: $customerName, customerPhone: $customerPhone, lineItems: $lineItems, subtotal: $subtotal, discountAmount: $discountAmount, deliveryCharge: $deliveryCharge, total: $total, paymentMode: $paymentMode, upiId: $upiId, deliveryNote: $deliveryNote, expectedDeliveryDate: $expectedDeliveryDate, slipImageUrl: $slipImageUrl, gstEnabled: $gstEnabled, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$OrderSlipCopyWith<$Res>
    implements $OrderSlipCopyWith<$Res> {
  factory _$OrderSlipCopyWith(
          _OrderSlip value, $Res Function(_OrderSlip) _then) =
      __$OrderSlipCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? inquiryId,
      String slipNumber,
      String customerName,
      String? customerPhone,
      List<OrderLineItem> lineItems,
      double subtotal,
      double discountAmount,
      double deliveryCharge,
      double total,
      PaymentMode paymentMode,
      String? upiId,
      String? deliveryNote,
      DateTime? expectedDeliveryDate,
      String? slipImageUrl,
      bool gstEnabled,
      DateTime createdAt});
}

/// @nodoc
class __$OrderSlipCopyWithImpl<$Res> implements _$OrderSlipCopyWith<$Res> {
  __$OrderSlipCopyWithImpl(this._self, this._then);

  final _OrderSlip _self;
  final $Res Function(_OrderSlip) _then;

  /// Create a copy of OrderSlip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? inquiryId = freezed,
    Object? slipNumber = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? lineItems = null,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? deliveryCharge = null,
    Object? total = null,
    Object? paymentMode = null,
    Object? upiId = freezed,
    Object? deliveryNote = freezed,
    Object? expectedDeliveryDate = freezed,
    Object? slipImageUrl = freezed,
    Object? gstEnabled = null,
    Object? createdAt = null,
  }) {
    return _then(_OrderSlip(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      inquiryId: freezed == inquiryId
          ? _self.inquiryId
          : inquiryId // ignore: cast_nullable_to_non_nullable
              as String?,
      slipNumber: null == slipNumber
          ? _self.slipNumber
          : slipNumber // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      lineItems: null == lineItems
          ? _self._lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as List<OrderLineItem>,
      subtotal: null == subtotal
          ? _self.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      discountAmount: null == discountAmount
          ? _self.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as double,
      deliveryCharge: null == deliveryCharge
          ? _self.deliveryCharge
          : deliveryCharge // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMode: null == paymentMode
          ? _self.paymentMode
          : paymentMode // ignore: cast_nullable_to_non_nullable
              as PaymentMode,
      upiId: freezed == upiId
          ? _self.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryNote: freezed == deliveryNote
          ? _self.deliveryNote
          : deliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedDeliveryDate: freezed == expectedDeliveryDate
          ? _self.expectedDeliveryDate
          : expectedDeliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      slipImageUrl: freezed == slipImageUrl
          ? _self.slipImageUrl
          : slipImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gstEnabled: null == gstEnabled
          ? _self.gstEnabled
          : gstEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
