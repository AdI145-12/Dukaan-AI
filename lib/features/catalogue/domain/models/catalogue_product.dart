import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalogue_product.freezed.dart';

@freezed
abstract class CatalogueVariantGroup with _$CatalogueVariantGroup {
	const factory CatalogueVariantGroup({
		required String name,
		@Default(<String>[]) List<String> options,
	}) = _CatalogueVariantGroup;
}

@freezed
abstract class CatalogueProduct with _$CatalogueProduct {
	const factory CatalogueProduct({
		required String id,
		required String userId,
		required String name,
		required double price,
		required String category,
		@Default(<CatalogueVariantGroup>[]) List<CatalogueVariantGroup> variants,
		@Default(StockStatus.inStock) StockStatus stockStatus,
		int? quantity,
		required String imageUrl,
		@Default('') String description,
		@Default(<String>[]) List<String> tags,
		@Default(<String>[]) List<String> suggestedCaptions,
		required DateTime createdAt,
		required DateTime updatedAt,
	}) = _CatalogueProduct;

	/// Creates a product model from a Firestore-like document object.
	factory CatalogueProduct.fromDoc(
		Object? doc, {
		String fallbackUserId = '',
	}) {
		final dynamic typedDoc = doc;
		final Map<String, dynamic> data = _toMap(typedDoc?.data());
		final Object? rawId = typedDoc?.id;
		final String id = rawId is String ? rawId : '';
		return CatalogueProduct.fromMap(
			data,
			id: id,
			fallbackUserId: fallbackUserId,
		);
	}

	/// Creates a product model from a map with explicit document [id].
	factory CatalogueProduct.fromMap(
		Map<String, dynamic> data, {
		required String id,
		String fallbackUserId = '',
	}) {
		return CatalogueProduct(
			id: id,
			userId: _readString(data[FirestoreFields.userId], fallbackUserId),
			name: _readString(data[FirestoreFields.name], ''),
			price: _toDouble(data[FirestoreFields.price]),
			category: _readString(data[FirestoreFields.category], ''),
			variants: _toVariantGroups(data[FirestoreFields.variants]),
			stockStatus: StockStatusHelper.stockStatusFromString(
				_readString(data[FirestoreFields.productStockStatus], ''),
			),
			quantity: _toNullableInt(
				data[FirestoreFields.productQuantity] ?? data[FirestoreFields.stock],
			),
			imageUrl: _readString(data[FirestoreFields.imageUrl], ''),
			description: _readString(data[FirestoreFields.description], ''),
			tags: _toStringList(data[FirestoreFields.tags]),
			suggestedCaptions:
					_toStringList(data[FirestoreFields.suggestedCaptions]),
			createdAt: _toDateTime(data[FirestoreFields.createdAt]),
			updatedAt: _toDateTime(data[FirestoreFields.updatedAt]),
		);
	}
}

extension CatalogueProductFirestoreX on CatalogueProduct {
	/// Converts product model into Firestore write payload.
	Map<String, dynamic> toFirestore() {
		return <String, dynamic>{
			FirestoreFields.userId: userId,
			FirestoreFields.name: name.trim(),
			FirestoreFields.price: price,
			FirestoreFields.category: category.trim(),
			FirestoreFields.variants: variants
					.map(
						(CatalogueVariantGroup group) => <String, dynamic>{
							FirestoreFields.variantType: group.name,
							FirestoreFields.options: group.options,
						},
					)
					.toList(growable: false),
			FirestoreFields.productStockStatus:
					StockStatusHelper.stockStatusToString(stockStatus),
			FirestoreFields.productQuantity: quantity,
			// Keep legacy key populated for older readers.
			FirestoreFields.stock: quantity,
			FirestoreFields.imageUrl: imageUrl,
			FirestoreFields.description: description.trim(),
			FirestoreFields.tags: tags,
			FirestoreFields.suggestedCaptions: suggestedCaptions,
			FirestoreFields.createdAt: createdAt,
			FirestoreFields.updatedAt: updatedAt,
		};
	}
}

extension CatalogueProductStockCompatX on CatalogueProduct {
	int? get stock => quantity;
}

Map<String, dynamic> _toMap(Object? raw) {
	if (raw is Map<String, dynamic>) {
		return raw;
	}
	if (raw is Map<Object?, Object?>) {
		return raw.map<String, dynamic>(
			(Object? key, Object? value) => MapEntry(key.toString(), value),
		);
	}
	return <String, dynamic>{};
}

String _readString(Object? raw, String fallback) {
	if (raw is String && raw.trim().isNotEmpty) {
		return raw.trim();
	}
	return fallback;
}

double _toDouble(Object? raw) {
	if (raw is num) {
		return raw.toDouble();
	}
	if (raw is String) {
		return double.tryParse(raw.trim()) ?? 0;
	}
	return 0;
}

int? _toNullableInt(Object? raw) {
	if (raw == null) {
		return null;
	}
	if (raw is num) {
		return raw.toInt();
	}
	if (raw is String) {
		return int.tryParse(raw.trim());
	}
	return null;
}

DateTime _toDateTime(Object? raw) {
	if (raw is DateTime) {
		return raw;
	}
	if (raw is String) {
		return DateTime.tryParse(raw) ?? DateTime.now();
	}
	try {
		final dynamic converted = (raw as dynamic)?.toDate();
		if (converted is DateTime) {
			return converted;
		}
	} catch (_) {
		// Fall through.
	}
	return DateTime.now();
}

List<String> _toStringList(Object? raw) {
	if (raw is! List<Object?>) {
		return const <String>[];
	}

	final List<String> values = <String>[];
	for (final Object? item in raw) {
		final String value = item?.toString().trim() ?? '';
		if (value.isEmpty || values.contains(value)) {
			continue;
		}
		values.add(value);
	}
	return values;
}

List<CatalogueVariantGroup> _toVariantGroups(Object? raw) {
	if (raw is! List<Object?>) {
		return const <CatalogueVariantGroup>[];
	}

	final List<CatalogueVariantGroup> groups = <CatalogueVariantGroup>[];
	for (final Object? item in raw) {
		final Map<String, dynamic> map = _toMap(item);
		final String name = _readString(map[FirestoreFields.variantType], '');
		if (name.isEmpty) {
			continue;
		}

		final List<String> options = _toStringList(map[FirestoreFields.options]);
		if (options.isEmpty) {
			continue;
		}

		groups.add(CatalogueVariantGroup(name: name, options: options));
	}

	return groups;
}