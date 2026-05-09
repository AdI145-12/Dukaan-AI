// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_slip_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderSlipState {
  List<OrderSlip> get slips;
  bool get isGeneratingImage;
  List<OrderLineItem> get draftLineItems;
  String get draftCustomerName;
  String? get draftCustomerPhone;
  double get draftDiscount;
  double get draftDeliveryCharge;
  PaymentMode get draftPaymentMode;
  String? get draftDeliveryNote;
  bool get draftGstEnabled;
  String? get prefillInquiryId;
  String? get draftUpiId;
  String? get errorMessage;
  OrderSlip? get latestCreatedSlip;
  String? get stockNudgeProductId;
  String? get stockNudgeProductName;

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderSlipStateCopyWith<OrderSlipState> get copyWith =>
      _$OrderSlipStateCopyWithImpl<OrderSlipState>(
          this as OrderSlipState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderSlipState &&
            const DeepCollectionEquality().equals(other.slips, slips) &&
            (identical(other.isGeneratingImage, isGeneratingImage) ||
                other.isGeneratingImage == isGeneratingImage) &&
            const DeepCollectionEquality()
                .equals(other.draftLineItems, draftLineItems) &&
            (identical(other.draftCustomerName, draftCustomerName) ||
                other.draftCustomerName == draftCustomerName) &&
            (identical(other.draftCustomerPhone, draftCustomerPhone) ||
                other.draftCustomerPhone == draftCustomerPhone) &&
            (identical(other.draftDiscount, draftDiscount) ||
                other.draftDiscount == draftDiscount) &&
            (identical(other.draftDeliveryCharge, draftDeliveryCharge) ||
                other.draftDeliveryCharge == draftDeliveryCharge) &&
            (identical(other.draftPaymentMode, draftPaymentMode) ||
                other.draftPaymentMode == draftPaymentMode) &&
            (identical(other.draftDeliveryNote, draftDeliveryNote) ||
                other.draftDeliveryNote == draftDeliveryNote) &&
            (identical(other.draftGstEnabled, draftGstEnabled) ||
                other.draftGstEnabled == draftGstEnabled) &&
            (identical(other.prefillInquiryId, prefillInquiryId) ||
                other.prefillInquiryId == prefillInquiryId) &&
            (identical(other.draftUpiId, draftUpiId) ||
                other.draftUpiId == draftUpiId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.latestCreatedSlip, latestCreatedSlip) ||
                other.latestCreatedSlip == latestCreatedSlip) &&
            (identical(other.stockNudgeProductId, stockNudgeProductId) ||
                other.stockNudgeProductId == stockNudgeProductId) &&
            (identical(other.stockNudgeProductName, stockNudgeProductName) ||
                other.stockNudgeProductName == stockNudgeProductName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(slips),
      isGeneratingImage,
      const DeepCollectionEquality().hash(draftLineItems),
      draftCustomerName,
      draftCustomerPhone,
      draftDiscount,
      draftDeliveryCharge,
      draftPaymentMode,
      draftDeliveryNote,
      draftGstEnabled,
      prefillInquiryId,
      draftUpiId,
      errorMessage,
      latestCreatedSlip,
      stockNudgeProductId,
      stockNudgeProductName);

  @override
  String toString() {
    return 'OrderSlipState(slips: $slips, isGeneratingImage: $isGeneratingImage, draftLineItems: $draftLineItems, draftCustomerName: $draftCustomerName, draftCustomerPhone: $draftCustomerPhone, draftDiscount: $draftDiscount, draftDeliveryCharge: $draftDeliveryCharge, draftPaymentMode: $draftPaymentMode, draftDeliveryNote: $draftDeliveryNote, draftGstEnabled: $draftGstEnabled, prefillInquiryId: $prefillInquiryId, draftUpiId: $draftUpiId, errorMessage: $errorMessage, latestCreatedSlip: $latestCreatedSlip, stockNudgeProductId: $stockNudgeProductId, stockNudgeProductName: $stockNudgeProductName)';
  }
}

/// @nodoc
abstract mixin class $OrderSlipStateCopyWith<$Res> {
  factory $OrderSlipStateCopyWith(
          OrderSlipState value, $Res Function(OrderSlipState) _then) =
      _$OrderSlipStateCopyWithImpl;
  @useResult
  $Res call(
      {List<OrderSlip> slips,
      bool isGeneratingImage,
      List<OrderLineItem> draftLineItems,
      String draftCustomerName,
      String? draftCustomerPhone,
      double draftDiscount,
      double draftDeliveryCharge,
      PaymentMode draftPaymentMode,
      String? draftDeliveryNote,
      bool draftGstEnabled,
      String? prefillInquiryId,
      String? draftUpiId,
      String? errorMessage,
      OrderSlip? latestCreatedSlip,
      String? stockNudgeProductId,
      String? stockNudgeProductName});

  $OrderSlipCopyWith<$Res>? get latestCreatedSlip;
}

/// @nodoc
class _$OrderSlipStateCopyWithImpl<$Res>
    implements $OrderSlipStateCopyWith<$Res> {
  _$OrderSlipStateCopyWithImpl(this._self, this._then);

  final OrderSlipState _self;
  final $Res Function(OrderSlipState) _then;

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? slips = null,
    Object? isGeneratingImage = null,
    Object? draftLineItems = null,
    Object? draftCustomerName = null,
    Object? draftCustomerPhone = freezed,
    Object? draftDiscount = null,
    Object? draftDeliveryCharge = null,
    Object? draftPaymentMode = null,
    Object? draftDeliveryNote = freezed,
    Object? draftGstEnabled = null,
    Object? prefillInquiryId = freezed,
    Object? draftUpiId = freezed,
    Object? errorMessage = freezed,
    Object? latestCreatedSlip = freezed,
    Object? stockNudgeProductId = freezed,
    Object? stockNudgeProductName = freezed,
  }) {
    return _then(_self.copyWith(
      slips: null == slips
          ? _self.slips
          : slips // ignore: cast_nullable_to_non_nullable
              as List<OrderSlip>,
      isGeneratingImage: null == isGeneratingImage
          ? _self.isGeneratingImage
          : isGeneratingImage // ignore: cast_nullable_to_non_nullable
              as bool,
      draftLineItems: null == draftLineItems
          ? _self.draftLineItems
          : draftLineItems // ignore: cast_nullable_to_non_nullable
              as List<OrderLineItem>,
      draftCustomerName: null == draftCustomerName
          ? _self.draftCustomerName
          : draftCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      draftCustomerPhone: freezed == draftCustomerPhone
          ? _self.draftCustomerPhone
          : draftCustomerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      draftDiscount: null == draftDiscount
          ? _self.draftDiscount
          : draftDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      draftDeliveryCharge: null == draftDeliveryCharge
          ? _self.draftDeliveryCharge
          : draftDeliveryCharge // ignore: cast_nullable_to_non_nullable
              as double,
      draftPaymentMode: null == draftPaymentMode
          ? _self.draftPaymentMode
          : draftPaymentMode // ignore: cast_nullable_to_non_nullable
              as PaymentMode,
      draftDeliveryNote: freezed == draftDeliveryNote
          ? _self.draftDeliveryNote
          : draftDeliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      draftGstEnabled: null == draftGstEnabled
          ? _self.draftGstEnabled
          : draftGstEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      prefillInquiryId: freezed == prefillInquiryId
          ? _self.prefillInquiryId
          : prefillInquiryId // ignore: cast_nullable_to_non_nullable
              as String?,
      draftUpiId: freezed == draftUpiId
          ? _self.draftUpiId
          : draftUpiId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      latestCreatedSlip: freezed == latestCreatedSlip
          ? _self.latestCreatedSlip
          : latestCreatedSlip // ignore: cast_nullable_to_non_nullable
              as OrderSlip?,
      stockNudgeProductId: freezed == stockNudgeProductId
          ? _self.stockNudgeProductId
          : stockNudgeProductId // ignore: cast_nullable_to_non_nullable
              as String?,
      stockNudgeProductName: freezed == stockNudgeProductName
          ? _self.stockNudgeProductName
          : stockNudgeProductName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderSlipCopyWith<$Res>? get latestCreatedSlip {
    if (_self.latestCreatedSlip == null) {
      return null;
    }

    return $OrderSlipCopyWith<$Res>(_self.latestCreatedSlip!, (value) {
      return _then(_self.copyWith(latestCreatedSlip: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OrderSlipState].
extension OrderSlipStatePatterns on OrderSlipState {
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
    TResult Function(_OrderSlipState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState() when $default != null:
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
    TResult Function(_OrderSlipState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState():
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
    TResult? Function(_OrderSlipState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState() when $default != null:
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
            List<OrderSlip> slips,
            bool isGeneratingImage,
            List<OrderLineItem> draftLineItems,
            String draftCustomerName,
            String? draftCustomerPhone,
            double draftDiscount,
            double draftDeliveryCharge,
            PaymentMode draftPaymentMode,
            String? draftDeliveryNote,
            bool draftGstEnabled,
            String? prefillInquiryId,
            String? draftUpiId,
            String? errorMessage,
            OrderSlip? latestCreatedSlip,
            String? stockNudgeProductId,
            String? stockNudgeProductName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState() when $default != null:
        return $default(
            _that.slips,
            _that.isGeneratingImage,
            _that.draftLineItems,
            _that.draftCustomerName,
            _that.draftCustomerPhone,
            _that.draftDiscount,
            _that.draftDeliveryCharge,
            _that.draftPaymentMode,
            _that.draftDeliveryNote,
            _that.draftGstEnabled,
            _that.prefillInquiryId,
            _that.draftUpiId,
            _that.errorMessage,
            _that.latestCreatedSlip,
            _that.stockNudgeProductId,
            _that.stockNudgeProductName);
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
            List<OrderSlip> slips,
            bool isGeneratingImage,
            List<OrderLineItem> draftLineItems,
            String draftCustomerName,
            String? draftCustomerPhone,
            double draftDiscount,
            double draftDeliveryCharge,
            PaymentMode draftPaymentMode,
            String? draftDeliveryNote,
            bool draftGstEnabled,
            String? prefillInquiryId,
            String? draftUpiId,
            String? errorMessage,
            OrderSlip? latestCreatedSlip,
            String? stockNudgeProductId,
            String? stockNudgeProductName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState():
        return $default(
            _that.slips,
            _that.isGeneratingImage,
            _that.draftLineItems,
            _that.draftCustomerName,
            _that.draftCustomerPhone,
            _that.draftDiscount,
            _that.draftDeliveryCharge,
            _that.draftPaymentMode,
            _that.draftDeliveryNote,
            _that.draftGstEnabled,
            _that.prefillInquiryId,
            _that.draftUpiId,
            _that.errorMessage,
            _that.latestCreatedSlip,
            _that.stockNudgeProductId,
            _that.stockNudgeProductName);
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
            List<OrderSlip> slips,
            bool isGeneratingImage,
            List<OrderLineItem> draftLineItems,
            String draftCustomerName,
            String? draftCustomerPhone,
            double draftDiscount,
            double draftDeliveryCharge,
            PaymentMode draftPaymentMode,
            String? draftDeliveryNote,
            bool draftGstEnabled,
            String? prefillInquiryId,
            String? draftUpiId,
            String? errorMessage,
            OrderSlip? latestCreatedSlip,
            String? stockNudgeProductId,
            String? stockNudgeProductName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderSlipState() when $default != null:
        return $default(
            _that.slips,
            _that.isGeneratingImage,
            _that.draftLineItems,
            _that.draftCustomerName,
            _that.draftCustomerPhone,
            _that.draftDiscount,
            _that.draftDeliveryCharge,
            _that.draftPaymentMode,
            _that.draftDeliveryNote,
            _that.draftGstEnabled,
            _that.prefillInquiryId,
            _that.draftUpiId,
            _that.errorMessage,
            _that.latestCreatedSlip,
            _that.stockNudgeProductId,
            _that.stockNudgeProductName);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OrderSlipState implements OrderSlipState {
  const _OrderSlipState(
      {final List<OrderSlip> slips = const <OrderSlip>[],
      this.isGeneratingImage = false,
      final List<OrderLineItem> draftLineItems = const <OrderLineItem>[],
      this.draftCustomerName = '',
      this.draftCustomerPhone,
      this.draftDiscount = 0,
      this.draftDeliveryCharge = 0,
      this.draftPaymentMode = PaymentMode.pending,
      this.draftDeliveryNote,
      this.draftGstEnabled = false,
      this.prefillInquiryId,
      this.draftUpiId,
      this.errorMessage,
      this.latestCreatedSlip,
      this.stockNudgeProductId,
      this.stockNudgeProductName})
      : _slips = slips,
        _draftLineItems = draftLineItems;

  final List<OrderSlip> _slips;
  @override
  @JsonKey()
  List<OrderSlip> get slips {
    if (_slips is EqualUnmodifiableListView) return _slips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slips);
  }

  @override
  @JsonKey()
  final bool isGeneratingImage;
  final List<OrderLineItem> _draftLineItems;
  @override
  @JsonKey()
  List<OrderLineItem> get draftLineItems {
    if (_draftLineItems is EqualUnmodifiableListView) return _draftLineItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_draftLineItems);
  }

  @override
  @JsonKey()
  final String draftCustomerName;
  @override
  final String? draftCustomerPhone;
  @override
  @JsonKey()
  final double draftDiscount;
  @override
  @JsonKey()
  final double draftDeliveryCharge;
  @override
  @JsonKey()
  final PaymentMode draftPaymentMode;
  @override
  final String? draftDeliveryNote;
  @override
  @JsonKey()
  final bool draftGstEnabled;
  @override
  final String? prefillInquiryId;
  @override
  final String? draftUpiId;
  @override
  final String? errorMessage;
  @override
  final OrderSlip? latestCreatedSlip;
  @override
  final String? stockNudgeProductId;
  @override
  final String? stockNudgeProductName;

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderSlipStateCopyWith<_OrderSlipState> get copyWith =>
      __$OrderSlipStateCopyWithImpl<_OrderSlipState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderSlipState &&
            const DeepCollectionEquality().equals(other._slips, _slips) &&
            (identical(other.isGeneratingImage, isGeneratingImage) ||
                other.isGeneratingImage == isGeneratingImage) &&
            const DeepCollectionEquality()
                .equals(other._draftLineItems, _draftLineItems) &&
            (identical(other.draftCustomerName, draftCustomerName) ||
                other.draftCustomerName == draftCustomerName) &&
            (identical(other.draftCustomerPhone, draftCustomerPhone) ||
                other.draftCustomerPhone == draftCustomerPhone) &&
            (identical(other.draftDiscount, draftDiscount) ||
                other.draftDiscount == draftDiscount) &&
            (identical(other.draftDeliveryCharge, draftDeliveryCharge) ||
                other.draftDeliveryCharge == draftDeliveryCharge) &&
            (identical(other.draftPaymentMode, draftPaymentMode) ||
                other.draftPaymentMode == draftPaymentMode) &&
            (identical(other.draftDeliveryNote, draftDeliveryNote) ||
                other.draftDeliveryNote == draftDeliveryNote) &&
            (identical(other.draftGstEnabled, draftGstEnabled) ||
                other.draftGstEnabled == draftGstEnabled) &&
            (identical(other.prefillInquiryId, prefillInquiryId) ||
                other.prefillInquiryId == prefillInquiryId) &&
            (identical(other.draftUpiId, draftUpiId) ||
                other.draftUpiId == draftUpiId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.latestCreatedSlip, latestCreatedSlip) ||
                other.latestCreatedSlip == latestCreatedSlip) &&
            (identical(other.stockNudgeProductId, stockNudgeProductId) ||
                other.stockNudgeProductId == stockNudgeProductId) &&
            (identical(other.stockNudgeProductName, stockNudgeProductName) ||
                other.stockNudgeProductName == stockNudgeProductName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_slips),
      isGeneratingImage,
      const DeepCollectionEquality().hash(_draftLineItems),
      draftCustomerName,
      draftCustomerPhone,
      draftDiscount,
      draftDeliveryCharge,
      draftPaymentMode,
      draftDeliveryNote,
      draftGstEnabled,
      prefillInquiryId,
      draftUpiId,
      errorMessage,
      latestCreatedSlip,
      stockNudgeProductId,
      stockNudgeProductName);

  @override
  String toString() {
    return 'OrderSlipState(slips: $slips, isGeneratingImage: $isGeneratingImage, draftLineItems: $draftLineItems, draftCustomerName: $draftCustomerName, draftCustomerPhone: $draftCustomerPhone, draftDiscount: $draftDiscount, draftDeliveryCharge: $draftDeliveryCharge, draftPaymentMode: $draftPaymentMode, draftDeliveryNote: $draftDeliveryNote, draftGstEnabled: $draftGstEnabled, prefillInquiryId: $prefillInquiryId, draftUpiId: $draftUpiId, errorMessage: $errorMessage, latestCreatedSlip: $latestCreatedSlip, stockNudgeProductId: $stockNudgeProductId, stockNudgeProductName: $stockNudgeProductName)';
  }
}

/// @nodoc
abstract mixin class _$OrderSlipStateCopyWith<$Res>
    implements $OrderSlipStateCopyWith<$Res> {
  factory _$OrderSlipStateCopyWith(
          _OrderSlipState value, $Res Function(_OrderSlipState) _then) =
      __$OrderSlipStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<OrderSlip> slips,
      bool isGeneratingImage,
      List<OrderLineItem> draftLineItems,
      String draftCustomerName,
      String? draftCustomerPhone,
      double draftDiscount,
      double draftDeliveryCharge,
      PaymentMode draftPaymentMode,
      String? draftDeliveryNote,
      bool draftGstEnabled,
      String? prefillInquiryId,
      String? draftUpiId,
      String? errorMessage,
      OrderSlip? latestCreatedSlip,
      String? stockNudgeProductId,
      String? stockNudgeProductName});

  @override
  $OrderSlipCopyWith<$Res>? get latestCreatedSlip;
}

/// @nodoc
class __$OrderSlipStateCopyWithImpl<$Res>
    implements _$OrderSlipStateCopyWith<$Res> {
  __$OrderSlipStateCopyWithImpl(this._self, this._then);

  final _OrderSlipState _self;
  final $Res Function(_OrderSlipState) _then;

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? slips = null,
    Object? isGeneratingImage = null,
    Object? draftLineItems = null,
    Object? draftCustomerName = null,
    Object? draftCustomerPhone = freezed,
    Object? draftDiscount = null,
    Object? draftDeliveryCharge = null,
    Object? draftPaymentMode = null,
    Object? draftDeliveryNote = freezed,
    Object? draftGstEnabled = null,
    Object? prefillInquiryId = freezed,
    Object? draftUpiId = freezed,
    Object? errorMessage = freezed,
    Object? latestCreatedSlip = freezed,
    Object? stockNudgeProductId = freezed,
    Object? stockNudgeProductName = freezed,
  }) {
    return _then(_OrderSlipState(
      slips: null == slips
          ? _self._slips
          : slips // ignore: cast_nullable_to_non_nullable
              as List<OrderSlip>,
      isGeneratingImage: null == isGeneratingImage
          ? _self.isGeneratingImage
          : isGeneratingImage // ignore: cast_nullable_to_non_nullable
              as bool,
      draftLineItems: null == draftLineItems
          ? _self._draftLineItems
          : draftLineItems // ignore: cast_nullable_to_non_nullable
              as List<OrderLineItem>,
      draftCustomerName: null == draftCustomerName
          ? _self.draftCustomerName
          : draftCustomerName // ignore: cast_nullable_to_non_nullable
              as String,
      draftCustomerPhone: freezed == draftCustomerPhone
          ? _self.draftCustomerPhone
          : draftCustomerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      draftDiscount: null == draftDiscount
          ? _self.draftDiscount
          : draftDiscount // ignore: cast_nullable_to_non_nullable
              as double,
      draftDeliveryCharge: null == draftDeliveryCharge
          ? _self.draftDeliveryCharge
          : draftDeliveryCharge // ignore: cast_nullable_to_non_nullable
              as double,
      draftPaymentMode: null == draftPaymentMode
          ? _self.draftPaymentMode
          : draftPaymentMode // ignore: cast_nullable_to_non_nullable
              as PaymentMode,
      draftDeliveryNote: freezed == draftDeliveryNote
          ? _self.draftDeliveryNote
          : draftDeliveryNote // ignore: cast_nullable_to_non_nullable
              as String?,
      draftGstEnabled: null == draftGstEnabled
          ? _self.draftGstEnabled
          : draftGstEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      prefillInquiryId: freezed == prefillInquiryId
          ? _self.prefillInquiryId
          : prefillInquiryId // ignore: cast_nullable_to_non_nullable
              as String?,
      draftUpiId: freezed == draftUpiId
          ? _self.draftUpiId
          : draftUpiId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      latestCreatedSlip: freezed == latestCreatedSlip
          ? _self.latestCreatedSlip
          : latestCreatedSlip // ignore: cast_nullable_to_non_nullable
              as OrderSlip?,
      stockNudgeProductId: freezed == stockNudgeProductId
          ? _self.stockNudgeProductId
          : stockNudgeProductId // ignore: cast_nullable_to_non_nullable
              as String?,
      stockNudgeProductName: freezed == stockNudgeProductName
          ? _self.stockNudgeProductName
          : stockNudgeProductName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OrderSlipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderSlipCopyWith<$Res>? get latestCreatedSlip {
    if (_self.latestCreatedSlip == null) {
      return null;
    }

    return $OrderSlipCopyWith<$Res>(_self.latestCreatedSlip!, (value) {
      return _then(_self.copyWith(latestCreatedSlip: value));
    });
  }
}

// dart format on
