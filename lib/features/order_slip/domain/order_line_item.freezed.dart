// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_line_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderLineItem {
  String? get productId;
  String get productName;
  String? get productImageUrl;
  double get unitPrice;
  int get quantity;
  String? get variantLabel;

  /// Create a copy of OrderLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrderLineItemCopyWith<OrderLineItem> get copyWith =>
      _$OrderLineItemCopyWithImpl<OrderLineItem>(
          this as OrderLineItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OrderLineItem &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productImageUrl, productImageUrl) ||
                other.productImageUrl == productImageUrl) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, productId, productName,
      productImageUrl, unitPrice, quantity, variantLabel);

  @override
  String toString() {
    return 'OrderLineItem(productId: $productId, productName: $productName, productImageUrl: $productImageUrl, unitPrice: $unitPrice, quantity: $quantity, variantLabel: $variantLabel)';
  }
}

/// @nodoc
abstract mixin class $OrderLineItemCopyWith<$Res> {
  factory $OrderLineItemCopyWith(
          OrderLineItem value, $Res Function(OrderLineItem) _then) =
      _$OrderLineItemCopyWithImpl;
  @useResult
  $Res call(
      {String? productId,
      String productName,
      String? productImageUrl,
      double unitPrice,
      int quantity,
      String? variantLabel});
}

/// @nodoc
class _$OrderLineItemCopyWithImpl<$Res>
    implements $OrderLineItemCopyWith<$Res> {
  _$OrderLineItemCopyWithImpl(this._self, this._then);

  final OrderLineItem _self;
  final $Res Function(OrderLineItem) _then;

  /// Create a copy of OrderLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = freezed,
    Object? productName = null,
    Object? productImageUrl = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? variantLabel = freezed,
  }) {
    return _then(_self.copyWith(
      productId: freezed == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productImageUrl: freezed == productImageUrl
          ? _self.productImageUrl
          : productImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      variantLabel: freezed == variantLabel
          ? _self.variantLabel
          : variantLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [OrderLineItem].
extension OrderLineItemPatterns on OrderLineItem {
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
    TResult Function(_OrderLineItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem() when $default != null:
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
    TResult Function(_OrderLineItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem():
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
    TResult? Function(_OrderLineItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem() when $default != null:
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
            String? productId,
            String productName,
            String? productImageUrl,
            double unitPrice,
            int quantity,
            String? variantLabel)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem() when $default != null:
        return $default(
            _that.productId,
            _that.productName,
            _that.productImageUrl,
            _that.unitPrice,
            _that.quantity,
            _that.variantLabel);
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
            String? productId,
            String productName,
            String? productImageUrl,
            double unitPrice,
            int quantity,
            String? variantLabel)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem():
        return $default(
            _that.productId,
            _that.productName,
            _that.productImageUrl,
            _that.unitPrice,
            _that.quantity,
            _that.variantLabel);
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
            String? productId,
            String productName,
            String? productImageUrl,
            double unitPrice,
            int quantity,
            String? variantLabel)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OrderLineItem() when $default != null:
        return $default(
            _that.productId,
            _that.productName,
            _that.productImageUrl,
            _that.unitPrice,
            _that.quantity,
            _that.variantLabel);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OrderLineItem extends OrderLineItem {
  const _OrderLineItem(
      {this.productId,
      required this.productName,
      this.productImageUrl,
      required this.unitPrice,
      this.quantity = 1,
      this.variantLabel})
      : super._();

  @override
  final String? productId;
  @override
  final String productName;
  @override
  final String? productImageUrl;
  @override
  final double unitPrice;
  @override
  @JsonKey()
  final int quantity;
  @override
  final String? variantLabel;

  /// Create a copy of OrderLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrderLineItemCopyWith<_OrderLineItem> get copyWith =>
      __$OrderLineItemCopyWithImpl<_OrderLineItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OrderLineItem &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productImageUrl, productImageUrl) ||
                other.productImageUrl == productImageUrl) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.variantLabel, variantLabel) ||
                other.variantLabel == variantLabel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, productId, productName,
      productImageUrl, unitPrice, quantity, variantLabel);

  @override
  String toString() {
    return 'OrderLineItem(productId: $productId, productName: $productName, productImageUrl: $productImageUrl, unitPrice: $unitPrice, quantity: $quantity, variantLabel: $variantLabel)';
  }
}

/// @nodoc
abstract mixin class _$OrderLineItemCopyWith<$Res>
    implements $OrderLineItemCopyWith<$Res> {
  factory _$OrderLineItemCopyWith(
          _OrderLineItem value, $Res Function(_OrderLineItem) _then) =
      __$OrderLineItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? productId,
      String productName,
      String? productImageUrl,
      double unitPrice,
      int quantity,
      String? variantLabel});
}

/// @nodoc
class __$OrderLineItemCopyWithImpl<$Res>
    implements _$OrderLineItemCopyWith<$Res> {
  __$OrderLineItemCopyWithImpl(this._self, this._then);

  final _OrderLineItem _self;
  final $Res Function(_OrderLineItem) _then;

  /// Create a copy of OrderLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productId = freezed,
    Object? productName = null,
    Object? productImageUrl = freezed,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? variantLabel = freezed,
  }) {
    return _then(_OrderLineItem(
      productId: freezed == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productImageUrl: freezed == productImageUrl
          ? _self.productImageUrl
          : productImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      variantLabel: freezed == variantLabel
          ? _self.variantLabel
          : variantLabel // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
