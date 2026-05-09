/// Firestore collection paths.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String generatedAds = 'generatedAds';
  static const String products = 'products';
  static const String khataEntries = 'khataEntries';
  static const String transactions = 'transactions';
  static const String usageEvents = 'usageEvents';
  static const String orderSlipsCollection = 'orderSlips';

  // S2 — Inquiry Tracker
  static const String inquiriesCollection = 'inquiries';
}

/// Common Firestore field names.
class FirestoreFields {
  FirestoreFields._();

  static const String userId = 'userId';
  static const String createdAt = 'createdAt';
  static const String isSettled = 'isSettled';
  static const String customerName = 'customerName';
  static const String customerPhone = 'customerPhone';
  static const String amount = 'amount';
  static const String type = 'type';
  static const String note = 'note';
  static const String imageUrl = 'imageUrl';
  static const String thumbnailUrl = 'thumbnailUrl';
  static const String backgroundStyle = 'backgroundStyle';
  static const String name = 'name';
  static const String price = 'price';
  static const String variants = 'variants';
  static const String variantType = 'variantType';
  static const String options = 'options';
  static const String productStockStatus = 'stockStatus';
  static const String productQuantity = 'quantity';
  static const String productUpdatedAt = 'updatedAt';
  static const String stock = 'stock';
  static const String description = 'description';
  static const String tags = 'tags';
  static const String suggestedCaptions = 'suggestedCaptions';
  static const String captionHindi = 'captionHindi';
  static const String captionEnglish = 'captionEnglish';
  static const String shareCount = 'shareCount';
  static const String downloadCount = 'downloadCount';
  static const String festivalTag = 'festivalTag';
  static const String tier = 'tier';
  static const String creditsRemaining = 'creditsRemaining';
  static const String shopName = 'shopName';
  static const String ownerName = 'ownerName';
  static const String category = 'category';
  static const String city = 'city';
  static const String phone = 'phone';
  static const String language = 'language';
  static const String storeSlug = 'storeSlug';
  static const String storeBannerUrl = 'storeBannerUrl';
  static const String storeDescription = 'storeDescription';
  static const String storeViewsCount = 'storeViewsCount';
  static const String storeWhatsappClicks = 'storeWhatsappClicks';
  static const String storeIsPublished = 'storeIsPublished';
  static const String eventType = 'eventType';
  static const String creditsUsed = 'creditsUsed';
  static const String metadata = 'metadata';
  static const String status = 'status';
  static const String planId = 'planId';
  static const String amountPaise = 'amountPaise';
  static const String verifiedAt = 'verifiedAt';
  static const String updatedAt = 'updatedAt';

  // S5 — Order Slip
  static const String orderSlipId = 'id';
  static const String orderSlipUserId = 'userId';
  static const String orderSlipInquiryId = 'inquiryId';
  static const String orderSlipNumber = 'slipNumber';
  static const String orderSlipCustomerName = 'customerName';
  static const String orderSlipCustomerPhone = 'customerPhone';
  static const String orderSlipLineItems = 'lineItems';
  static const String orderSlipSubtotal = 'subtotal';
  static const String orderSlipDiscountAmount = 'discountAmount';
  static const String orderSlipDeliveryCharge = 'deliveryCharge';
  static const String orderSlipTotal = 'total';
  static const String orderSlipPaymentMode = 'paymentMode';
  static const String orderSlipUpiId = 'upiId';
  static const String orderSlipDeliveryNote = 'deliveryNote';
  static const String orderSlipExpectedDeliveryDate = 'expectedDeliveryDate';
  static const String orderSlipSlipImageUrl = 'slipImageUrl';
  static const String orderSlipGstEnabled = 'gstEnabled';
  static const String orderSlipCreatedAt = 'createdAt';

  // S5 — Order Line Item
  static const String lineItemProductId = 'productId';
  static const String lineItemProductName = 'productName';
  static const String lineItemProductImageUrl = 'productImageUrl';
  static const String lineItemUnitPrice = 'unitPrice';
  static const String lineItemQuantity = 'quantity';
  static const String lineItemVariantLabel = 'variantLabel';
}

abstract class InquiryFields {
  static const String id = 'id';
  static const String userId = 'userId';
  static const String customerName = 'customerName';
  static const String customerPhone = 'customerPhone';
  static const String productId = 'productId';
  static const String productAsked = 'productAsked';
  static const String source = 'source';
  static const String status = 'status';
  static const String notes = 'notes';
  static const String lastFollowUp = 'lastFollowUp';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}
