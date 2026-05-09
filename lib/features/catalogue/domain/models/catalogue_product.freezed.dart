// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalogue_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogueVariantGroup {
  String get name;
  List<String> get options;

  /// Create a copy of CatalogueVariantGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CatalogueVariantGroupCopyWith<CatalogueVariantGroup> get copyWith =>
      _$CatalogueVariantGroupCopyWithImpl<CatalogueVariantGroup>(
          this as CatalogueVariantGroup, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CatalogueVariantGroup &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other.options, options));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(options));

  @override
  String toString() {
    return 'CatalogueVariantGroup(name: $name, options: $options)';
  }
}

/// @nodoc
abstract mixin class $CatalogueVariantGroupCopyWith<$Res> {
  factory $CatalogueVariantGroupCopyWith(CatalogueVariantGroup value,
          $Res Function(CatalogueVariantGroup) _then) =
      _$CatalogueVariantGroupCopyWithImpl;
  @useResult
  $Res call({String name, List<String> options});
}

/// @nodoc
class _$CatalogueVariantGroupCopyWithImpl<$Res>
    implements $CatalogueVariantGroupCopyWith<$Res> {
  _$CatalogueVariantGroupCopyWithImpl(this._self, this._then);

  final CatalogueVariantGroup _self;
  final $Res Function(CatalogueVariantGroup) _then;

  /// Create a copy of CatalogueVariantGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? options = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _self.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CatalogueVariantGroup].
extension CatalogueVariantGroupPatterns on CatalogueVariantGroup {
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
    TResult Function(_CatalogueVariantGroup value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup() when $default != null:
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
    TResult Function(_CatalogueVariantGroup value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup():
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
    TResult? Function(_CatalogueVariantGroup value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup() when $default != null:
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
    TResult Function(String name, List<String> options)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup() when $default != null:
        return $default(_that.name, _that.options);
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
    TResult Function(String name, List<String> options) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup():
        return $default(_that.name, _that.options);
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
    TResult? Function(String name, List<String> options)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueVariantGroup() when $default != null:
        return $default(_that.name, _that.options);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CatalogueVariantGroup implements CatalogueVariantGroup {
  const _CatalogueVariantGroup(
      {required this.name, final List<String> options = const <String>[]})
      : _options = options;

  @override
  final String name;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  /// Create a copy of CatalogueVariantGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CatalogueVariantGroupCopyWith<_CatalogueVariantGroup> get copyWith =>
      __$CatalogueVariantGroupCopyWithImpl<_CatalogueVariantGroup>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CatalogueVariantGroup &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._options, _options));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_options));

  @override
  String toString() {
    return 'CatalogueVariantGroup(name: $name, options: $options)';
  }
}

/// @nodoc
abstract mixin class _$CatalogueVariantGroupCopyWith<$Res>
    implements $CatalogueVariantGroupCopyWith<$Res> {
  factory _$CatalogueVariantGroupCopyWith(_CatalogueVariantGroup value,
          $Res Function(_CatalogueVariantGroup) _then) =
      __$CatalogueVariantGroupCopyWithImpl;
  @override
  @useResult
  $Res call({String name, List<String> options});
}

/// @nodoc
class __$CatalogueVariantGroupCopyWithImpl<$Res>
    implements _$CatalogueVariantGroupCopyWith<$Res> {
  __$CatalogueVariantGroupCopyWithImpl(this._self, this._then);

  final _CatalogueVariantGroup _self;
  final $Res Function(_CatalogueVariantGroup) _then;

  /// Create a copy of CatalogueVariantGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? options = null,
  }) {
    return _then(_CatalogueVariantGroup(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _self._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$CatalogueProduct {
  String get id;
  String get userId;
  String get name;
  double get price;
  String get category;
  List<CatalogueVariantGroup> get variants;
  StockStatus get stockStatus;
  int? get quantity;
  String get imageUrl;
  String get description;
  List<String> get tags;
  List<String> get suggestedCaptions;
  DateTime get createdAt;
  DateTime get updatedAt;

  /// Create a copy of CatalogueProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CatalogueProductCopyWith<CatalogueProduct> get copyWith =>
      _$CatalogueProductCopyWithImpl<CatalogueProduct>(
          this as CatalogueProduct, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CatalogueProduct &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other.variants, variants) &&
            (identical(other.stockStatus, stockStatus) ||
                other.stockStatus == stockStatus) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.suggestedCaptions, suggestedCaptions) &&
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
      name,
      price,
      category,
      const DeepCollectionEquality().hash(variants),
      stockStatus,
      quantity,
      imageUrl,
      description,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(suggestedCaptions),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CatalogueProduct(id: $id, userId: $userId, name: $name, price: $price, category: $category, variants: $variants, stockStatus: $stockStatus, quantity: $quantity, imageUrl: $imageUrl, description: $description, tags: $tags, suggestedCaptions: $suggestedCaptions, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CatalogueProductCopyWith<$Res> {
  factory $CatalogueProductCopyWith(
          CatalogueProduct value, $Res Function(CatalogueProduct) _then) =
      _$CatalogueProductCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      double price,
      String category,
      List<CatalogueVariantGroup> variants,
      StockStatus stockStatus,
      int? quantity,
      String imageUrl,
      String description,
      List<String> tags,
      List<String> suggestedCaptions,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$CatalogueProductCopyWithImpl<$Res>
    implements $CatalogueProductCopyWith<$Res> {
  _$CatalogueProductCopyWithImpl(this._self, this._then);

  final CatalogueProduct _self;
  final $Res Function(CatalogueProduct) _then;

  /// Create a copy of CatalogueProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? price = null,
    Object? category = null,
    Object? variants = null,
    Object? stockStatus = null,
    Object? quantity = freezed,
    Object? imageUrl = null,
    Object? description = null,
    Object? tags = null,
    Object? suggestedCaptions = null,
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
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      variants: null == variants
          ? _self.variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<CatalogueVariantGroup>,
      stockStatus: null == stockStatus
          ? _self.stockStatus
          : stockStatus // ignore: cast_nullable_to_non_nullable
              as StockStatus,
      quantity: freezed == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestedCaptions: null == suggestedCaptions
          ? _self.suggestedCaptions
          : suggestedCaptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
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

/// Adds pattern-matching-related methods to [CatalogueProduct].
extension CatalogueProductPatterns on CatalogueProduct {
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
    TResult Function(_CatalogueProduct value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct() when $default != null:
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
    TResult Function(_CatalogueProduct value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct():
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
    TResult? Function(_CatalogueProduct value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct() when $default != null:
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
            String name,
            double price,
            String category,
            List<CatalogueVariantGroup> variants,
            StockStatus stockStatus,
            int? quantity,
            String imageUrl,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            DateTime createdAt,
            DateTime updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.price,
            _that.category,
            _that.variants,
            _that.stockStatus,
            _that.quantity,
            _that.imageUrl,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
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
            String name,
            double price,
            String category,
            List<CatalogueVariantGroup> variants,
            StockStatus stockStatus,
            int? quantity,
            String imageUrl,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            DateTime createdAt,
            DateTime updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct():
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.price,
            _that.category,
            _that.variants,
            _that.stockStatus,
            _that.quantity,
            _that.imageUrl,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
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
            String name,
            double price,
            String category,
            List<CatalogueVariantGroup> variants,
            StockStatus stockStatus,
            int? quantity,
            String imageUrl,
            String description,
            List<String> tags,
            List<String> suggestedCaptions,
            DateTime createdAt,
            DateTime updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CatalogueProduct() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.name,
            _that.price,
            _that.category,
            _that.variants,
            _that.stockStatus,
            _that.quantity,
            _that.imageUrl,
            _that.description,
            _that.tags,
            _that.suggestedCaptions,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CatalogueProduct implements CatalogueProduct {
  const _CatalogueProduct(
      {required this.id,
      required this.userId,
      required this.name,
      required this.price,
      required this.category,
      final List<CatalogueVariantGroup> variants =
          const <CatalogueVariantGroup>[],
      this.stockStatus = StockStatus.inStock,
      this.quantity,
      required this.imageUrl,
      this.description = '',
      final List<String> tags = const <String>[],
      final List<String> suggestedCaptions = const <String>[],
      required this.createdAt,
      required this.updatedAt})
      : _variants = variants,
        _tags = tags,
        _suggestedCaptions = suggestedCaptions;

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final double price;
  @override
  final String category;
  final List<CatalogueVariantGroup> _variants;
  @override
  @JsonKey()
  List<CatalogueVariantGroup> get variants {
    if (_variants is EqualUnmodifiableListView) return _variants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_variants);
  }

  @override
  @JsonKey()
  final StockStatus stockStatus;
  @override
  final int? quantity;
  @override
  final String imageUrl;
  @override
  @JsonKey()
  final String description;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _suggestedCaptions;
  @override
  @JsonKey()
  List<String> get suggestedCaptions {
    if (_suggestedCaptions is EqualUnmodifiableListView)
      return _suggestedCaptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestedCaptions);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  /// Create a copy of CatalogueProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CatalogueProductCopyWith<_CatalogueProduct> get copyWith =>
      __$CatalogueProductCopyWithImpl<_CatalogueProduct>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CatalogueProduct &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._variants, _variants) &&
            (identical(other.stockStatus, stockStatus) ||
                other.stockStatus == stockStatus) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._suggestedCaptions, _suggestedCaptions) &&
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
      name,
      price,
      category,
      const DeepCollectionEquality().hash(_variants),
      stockStatus,
      quantity,
      imageUrl,
      description,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_suggestedCaptions),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'CatalogueProduct(id: $id, userId: $userId, name: $name, price: $price, category: $category, variants: $variants, stockStatus: $stockStatus, quantity: $quantity, imageUrl: $imageUrl, description: $description, tags: $tags, suggestedCaptions: $suggestedCaptions, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CatalogueProductCopyWith<$Res>
    implements $CatalogueProductCopyWith<$Res> {
  factory _$CatalogueProductCopyWith(
          _CatalogueProduct value, $Res Function(_CatalogueProduct) _then) =
      __$CatalogueProductCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      double price,
      String category,
      List<CatalogueVariantGroup> variants,
      StockStatus stockStatus,
      int? quantity,
      String imageUrl,
      String description,
      List<String> tags,
      List<String> suggestedCaptions,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$CatalogueProductCopyWithImpl<$Res>
    implements _$CatalogueProductCopyWith<$Res> {
  __$CatalogueProductCopyWithImpl(this._self, this._then);

  final _CatalogueProduct _self;
  final $Res Function(_CatalogueProduct) _then;

  /// Create a copy of CatalogueProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? price = null,
    Object? category = null,
    Object? variants = null,
    Object? stockStatus = null,
    Object? quantity = freezed,
    Object? imageUrl = null,
    Object? description = null,
    Object? tags = null,
    Object? suggestedCaptions = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_CatalogueProduct(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      variants: null == variants
          ? _self._variants
          : variants // ignore: cast_nullable_to_non_nullable
              as List<CatalogueVariantGroup>,
      stockStatus: null == stockStatus
          ? _self.stockStatus
          : stockStatus // ignore: cast_nullable_to_non_nullable
              as StockStatus,
      quantity: freezed == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestedCaptions: null == suggestedCaptions
          ? _self._suggestedCaptions
          : suggestedCaptions // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
