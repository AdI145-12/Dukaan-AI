import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_metadata.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_source.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';

UserProfile testUserProfile({
  String id = 'test-user-id',
  String shopName = 'Test Dukaan',
  String tier = 'free',
  int credits = 3,
}) {
  return UserProfile(
    id: id,
    shopName: shopName,
    tier: tier,
    creditsRemaining: credits,
  );
}

CatalogueProduct testCatalogueProduct({
  String id = 'test-product-id',
  String userId = 'test-user-id',
  String name = 'Test Kurta',
  double price = 499.0,
  String category = 'clothing',
  String description = 'Sundar kurta hai yeh.',
  String imageUrl = 'https://example.com/product.jpg',
  StockStatus stockStatus = StockStatus.inStock,
  int? quantity,
  int? stock,
  List<CatalogueVariantGroup> variants = const <CatalogueVariantGroup>[],
  List<String> tags = const <String>['kurta', 'cotton', 'clothing'],
  List<String> suggestedCaptions = const <String>[
    'Naya collection aa gaya!',
    'Style mein rehna ho toh yeh lo.',
  ],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final DateTime timestamp = DateTime(2026, 4, 1);
  return CatalogueProduct(
    id: id,
    userId: userId,
    name: name,
    price: price,
    category: category,
    variants: variants,
    stockStatus: stockStatus,
    quantity: quantity ?? stock,
    imageUrl: imageUrl,
    description: description,
    tags: tags,
    suggestedCaptions: suggestedCaptions,
    createdAt: createdAt ?? timestamp,
    updatedAt: updatedAt ?? timestamp,
  );
}

CatalogueMetadata testCatalogueMetadata() {
  return const CatalogueMetadata(
    description: 'Ek sundar kurta, cotton ka bana hua.',
    tags: <String>['kurta', 'cotton', 'clothing'],
    suggestedCaptions: <String>[
      'Naya collection aa gaya!',
      'Style mein rehna ho toh yeh lo.',
    ],
  );
}

Inquiry testInquiry({
  String id = 'test-inquiry-id',
  String userId = 'test-user-id',
  String customerName = 'Test Customer',
  String? customerPhone = '+919876543210',
  String? productId,
  String productAsked = 'Test Kurta',
  InquirySource source = InquirySource.whatsapp,
  InquiryStatus status = InquiryStatus.newInquiry,
  String? notes,
  DateTime? updatedAt,
}) {
  return Inquiry(
    id: id,
    userId: userId,
    customerName: customerName,
    customerPhone: customerPhone,
    productId: productId,
    productAsked: productAsked,
    source: source,
    status: status,
    notes: notes,
    createdAt: DateTime(2026, 4, 1),
    updatedAt: updatedAt ?? DateTime(2026, 4, 10),
  );
}
