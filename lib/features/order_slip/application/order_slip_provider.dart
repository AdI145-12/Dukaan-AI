import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/order_slip/application/order_slip_state.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository.dart';
import 'package:dukaan_ai/features/order_slip/data/order_slip_repository_impl.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:dukaan_ai/shared/providers/catalogue_products_provider.dart';
import 'package:dukaan_ai/shared/providers/order_slip_actions_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

part 'order_slip_provider.g.dart';

class OrderSlipSellerProfile {
  const OrderSlipSellerProfile({
    required this.shopName,
    this.city,
    this.phone,
    this.upiId,
  });

  final String shopName;
  final String? city;
  final String? phone;
  final String? upiId;
}

@riverpod
Future<OrderSlipSellerProfile> orderSlipSellerProfile(Ref ref) async {
  final String userId = FirebaseService.currentUserId ?? '';
  if (userId.trim().isEmpty) {
    return const OrderSlipSellerProfile(shopName: AppStrings.shopNameFallback);
  }

  final dynamic snapshot =
      await FirebaseService.db.collection(FirestoreCollections.users).doc(userId).get();
  final bool exists = snapshot.exists as bool? ?? false;
  if (!exists) {
    return const OrderSlipSellerProfile(shopName: AppStrings.shopNameFallback);
  }

  final Map<String, dynamic> data = _toMap(snapshot.data());
  return OrderSlipSellerProfile(
    shopName: (data[FirestoreFields.shopName] as String?)?.trim().isNotEmpty ==
            true
        ? data[FirestoreFields.shopName] as String
        : AppStrings.shopNameFallback,
    city: data[FirestoreFields.city] as String?,
    phone: data[FirestoreFields.phone] as String?,
    upiId: data[FirestoreFields.orderSlipUpiId] as String?,
  );
}

@riverpod
class OrderSlipNotifier extends _$OrderSlipNotifier {
  @override
  Future<OrderSlipState> build() async {
    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.trim().isEmpty) {
      return const OrderSlipState();
    }

    final List<OrderSlip> slips =
        await ref.watch(orderSlipRepositoryProvider).getSlips(userId);
    return OrderSlipState(slips: slips);
  }

  /// Prefills draft values from an inquiry object.
  Future<void> prefillFromInquiry(Inquiry inquiry) async {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(
      current.copyWith(
        draftCustomerName: inquiry.customerName,
        draftCustomerPhone: inquiry.customerPhone,
        prefillInquiryId: inquiry.id,
        errorMessage: null,
      ),
    );

    final String? productId = inquiry.productId;
    if (productId != null && productId.trim().isNotEmpty) {
      await addProductFromCatalog(productId);
    }
  }

  /// Prefills inquiry-linked customer values using route data.
  Future<void> prefillFromParams({
    required String inquiryId,
    required String customerName,
    String? customerPhone,
    String? linkedProductId,
  }) async {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(
      current.copyWith(
        draftCustomerName: customerName,
        draftCustomerPhone: customerPhone,
        prefillInquiryId: inquiryId,
        errorMessage: null,
      ),
    );

    if (linkedProductId != null && linkedProductId.trim().isNotEmpty) {
      await addProductFromCatalog(linkedProductId);
    }
  }

  /// Prefills draft values from an already created slip.
  void prefillFromSlip(OrderSlip slip) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(
      current.copyWith(
        draftCustomerName: slip.customerName,
        draftCustomerPhone: slip.customerPhone,
        draftLineItems: slip.lineItems,
        draftDiscount: slip.discountAmount,
        draftDeliveryCharge: slip.deliveryCharge,
        draftPaymentMode: slip.paymentMode,
        draftDeliveryNote: slip.deliveryNote,
        draftGstEnabled: slip.gstEnabled,
        draftUpiId: slip.upiId,
        prefillInquiryId: slip.inquiryId,
        errorMessage: null,
      ),
    );
  }

  /// Adds one product from catalogue into draft line items.
  Future<void> addProductFromCatalog(String productId) async {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    final List<dynamic> products = await ref.read(catalogueProductsProvider.future);

    dynamic selected;
    for (final dynamic product in products) {
      final String id = (product.id as String?) ?? '';
      if (id == productId) {
        selected = product;
        break;
      }
    }

    if (selected == null) {
      state = AsyncData(current.copyWith(errorMessage: AppStrings.catalogueLoadFailed));
      return;
    }

    final List<OrderLineItem> nextItems = List<OrderLineItem>.from(
      current.draftLineItems,
      growable: true,
    );

    final int existingIndex = nextItems.indexWhere(
      (OrderLineItem item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      final OrderLineItem existing = nextItems[existingIndex];
      nextItems[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
      state = AsyncData(current.copyWith(draftLineItems: nextItems, errorMessage: null));
      return;
    }

    final String variantLabel = _buildVariantLabel(selected.variants as List<dynamic>? ?? <dynamic>[]);
    nextItems.add(
      OrderLineItem(
        productId: selected.id as String,
        productName: (selected.name as String?) ?? '',
        productImageUrl: selected.imageUrl as String?,
        unitPrice: (selected.price as num?)?.toDouble() ?? 0,
        quantity: 1,
        variantLabel: variantLabel.isEmpty ? null : variantLabel,
      ),
    );

    state = AsyncData(current.copyWith(draftLineItems: nextItems, errorMessage: null));
  }

  /// Adds one manually typed line item to draft.
  void addManualLineItem(String name, double price) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    final List<OrderLineItem> nextItems = List<OrderLineItem>.from(
      current.draftLineItems,
      growable: true,
    )
      ..add(
        OrderLineItem(
          productName: name.trim(),
          unitPrice: price,
          quantity: 1,
        ),
      );

    state = AsyncData(current.copyWith(draftLineItems: nextItems, errorMessage: null));
  }

  /// Removes one line item by index.
  void removeLineItem(int index) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (index < 0 || index >= current.draftLineItems.length) {
      return;
    }

    final List<OrderLineItem> nextItems = List<OrderLineItem>.from(
      current.draftLineItems,
      growable: true,
    )
      ..removeAt(index);

    state = AsyncData(current.copyWith(draftLineItems: nextItems));
  }

  /// Updates quantity for one line item.
  void updateLineItemQuantity(int index, int newQuantity) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (index < 0 || index >= current.draftLineItems.length) {
      return;
    }

    if (newQuantity < 1) {
      removeLineItem(index);
      return;
    }

    final List<OrderLineItem> nextItems = List<OrderLineItem>.from(
      current.draftLineItems,
      growable: true,
    );
    nextItems[index] = nextItems[index].copyWith(quantity: newQuantity);

    state = AsyncData(current.copyWith(draftLineItems: nextItems));
  }

  /// Updates unit price for one line item.
  void updateLineItemPrice(int index, double newPrice) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (index < 0 || index >= current.draftLineItems.length) {
      return;
    }

    final List<OrderLineItem> nextItems = List<OrderLineItem>.from(
      current.draftLineItems,
      growable: true,
    );
    nextItems[index] = nextItems[index].copyWith(unitPrice: newPrice);

    state = AsyncData(current.copyWith(draftLineItems: nextItems));
  }

  /// Updates draft customer name.
  void updateDraftCustomerName(String value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftCustomerName: value));
  }

  /// Updates draft customer phone.
  void updateDraftCustomerPhone(String? value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftCustomerPhone: value));
  }

  /// Updates draft discount.
  void updateDraftDiscount(double value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftDiscount: value));
  }

  /// Updates draft delivery charge.
  void updateDraftDeliveryCharge(double value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftDeliveryCharge: value));
  }

  /// Updates draft payment mode.
  void updateDraftPaymentMode(PaymentMode value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftPaymentMode: value));
  }

  /// Updates draft delivery note.
  void updateDraftDeliveryNote(String? value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftDeliveryNote: value));
  }

  /// Updates draft gst-enabled toggle.
  void updateDraftGstEnabled(bool value) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(draftGstEnabled: value));
  }

  /// Derived subtotal from current draft line items.
  double get computedSubtotal {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    return current.draftLineItems.fold<double>(
      0,
      (double running, OrderLineItem item) => running + item.subtotal,
    );
  }

  /// Derived final total = subtotal - discount + delivery.
  double get computedTotal {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    return computedSubtotal - current.draftDiscount + current.draftDeliveryCharge;
  }

  /// Creates one order slip, generates image, uploads to storage and updates Firestore.
  Future<void> createAndShareSlip(
    GlobalKey screenshotKey, {
    required ScreenshotController screenshotController,
  }) async {
    final bool hasScreenshotAnchor = screenshotKey.currentContext != null;

    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();

    if (current.draftLineItems.isEmpty) {
      state = AsyncData(current.copyWith(errorMessage: AppStrings.orderSlipProductsSection));
      return;
    }

    if (current.draftCustomerName.trim().isEmpty) {
      state = AsyncData(current.copyWith(errorMessage: AppStrings.orderSlipCustomerLabel));
      return;
    }

    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.trim().isEmpty) {
      state = AsyncData(current.copyWith(errorMessage: AppStrings.errorAuth));
      return;
    }

    final OrderSlipRepository repository = ref.read(orderSlipRepositoryProvider);
    final int slipCount = await repository.getSlipCount(userId);
    final DateTime now = DateTime.now();

    final OrderSlipSellerProfile profile =
        await ref.read(orderSlipSellerProfileProvider.future);

    final double subtotal = computedSubtotal;
    final double total = subtotal - current.draftDiscount + current.draftDeliveryCharge;

    final OrderSlip draft = OrderSlip(
      id: '',
      userId: userId,
      inquiryId: current.prefillInquiryId,
      slipNumber: '${AppStrings.slipNumberPrefix}-${now.year}-${slipCount + 1}',
      customerName: current.draftCustomerName.trim(),
      customerPhone: _nullableTrim(current.draftCustomerPhone),
      lineItems: current.draftLineItems,
      subtotal: subtotal,
      discountAmount: current.draftDiscount,
      deliveryCharge: current.draftDeliveryCharge,
      total: total,
      paymentMode: current.draftPaymentMode,
      upiId: _nullableTrim(current.draftUpiId) ?? _nullableTrim(profile.upiId),
      deliveryNote: _nullableTrim(current.draftDeliveryNote),
      slipImageUrl: null,
      gstEnabled: current.draftGstEnabled,
      createdAt: now,
    );

    final OrderSlip saved = await repository.createSlip(draft);

    state = AsyncData(
      current.copyWith(
        slips: <OrderSlip>[saved, ...current.slips],
        latestCreatedSlip: saved,
        isGeneratingImage: true,
        errorMessage: null,
      ),
    );

    try {
      final Uint8List? imageBytes = await screenshotController.capture(pixelRatio: 3);
      if (imageBytes != null) {
        final String imageUrl = await _uploadSlipImage(
          userId: userId,
          slipId: saved.id,
          imageBytes: imageBytes,
        );

        await repository.updateSlipImageUrl(saved.id, imageUrl);
        final OrderSlip withImage = saved.copyWith(slipImageUrl: imageUrl);
        _replaceSlipInState(withImage, isGeneratingImage: false);
      } else {
        if (!hasScreenshotAnchor) {
          state = AsyncData(
            (state.asData?.value ?? current).copyWith(
              errorMessage: AppStrings.errorCaptureGeneric,
            ),
          );
        }
        _replaceSlipInState(saved, isGeneratingImage: false);
      }
    } catch (_) {
      _replaceSlipInState(saved, isGeneratingImage: false);
    }

    final String? inquiryId = current.prefillInquiryId;
    if (inquiryId != null && inquiryId.trim().isNotEmpty) {
      unawaited(ref.read(inquiryOrderActionsProvider).markInquiryOrdered(inquiryId));
    }

    await _setStockNudgeIfNeeded(current.draftLineItems);

    final OrderSlipState latest = state.asData?.value ?? current;
    state = AsyncData(
      latest.copyWith(
        draftLineItems: const <OrderLineItem>[],
        draftDiscount: 0,
        draftDeliveryCharge: 0,
        draftDeliveryNote: null,
        draftGstEnabled: false,
        prefillInquiryId: null,
      ),
    );
  }

  /// Shares summary text to WhatsApp with optional customer phone prefill.
  Future<void> shareToWhatsApp(OrderSlip slip) async {
    final String encoded = Uri.encodeComponent(slip.whatsAppSummary);
    final String? cleanedPhone = _toIndianPhoneOrNull(slip.customerPhone);

    final Uri uri = cleanedPhone == null
        ? Uri.parse('https://wa.me/?text=$encoded')
        : Uri.parse('https://wa.me/$cleanedPhone?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Resolves a local png file path for one saved slip image url.
  Future<String?> getLocalImagePath(OrderSlip slip) async {
    final String imageUrl = (slip.slipImageUrl ?? '').trim();
    if (imageUrl.isEmpty) {
      return null;
    }

    if (imageUrl.startsWith('file://')) {
      return Uri.parse(imageUrl).toFilePath();
    }

    final Uri? uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return null;
    }

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/order-slip-${slip.id}.png');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  /// Adds this slip as a khata debit entry.
  Future<void> addToKhata(OrderSlip slip) {
    return ref.read(khataOrderActionsProvider).addOrderDebitEntry(
          customerName: slip.customerName,
          customerPhone: slip.customerPhone,
          amount: slip.total,
          note: 'Order ${slip.slipNumber}',
        );
  }

  /// Regenerates image for one existing slip and updates both storage and Firestore.
  Future<OrderSlip?> regenerateSlipImage(
    OrderSlip slip, {
    required ScreenshotController screenshotController,
  }) async {
    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.trim().isEmpty) {
      return null;
    }

    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(current.copyWith(isGeneratingImage: true));

    try {
      final Uint8List? bytes = await screenshotController.capture(pixelRatio: 3);
      if (bytes == null) {
        state = AsyncData(current.copyWith(isGeneratingImage: false));
        return null;
      }

      final String imageUrl = await _uploadSlipImage(
        userId: userId,
        slipId: slip.id,
        imageBytes: bytes,
      );

      await ref.read(orderSlipRepositoryProvider).updateSlipImageUrl(slip.id, imageUrl);

      final OrderSlip updated = slip.copyWith(slipImageUrl: imageUrl);
      _replaceSlipInState(updated, isGeneratingImage: false);
      return updated;
    } catch (_) {
      final OrderSlipState latest = state.asData?.value ?? current;
      state = AsyncData(latest.copyWith(isGeneratingImage: false));
      return null;
    }
  }

  /// Clears one-shot error banner text after UI consumes it.
  void clearErrorMessage() {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (current.errorMessage == null) {
      return;
    }
    state = AsyncData(current.copyWith(errorMessage: null));
  }

  /// Clears one-shot created slip event after navigation.
  void consumeLatestCreatedSlip() {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (current.latestCreatedSlip == null) {
      return;
    }
    state = AsyncData(current.copyWith(latestCreatedSlip: null));
  }

  /// Clears one-shot stock nudge event after UI consumes it.
  void clearStockNudge() {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    if (current.stockNudgeProductId == null && current.stockNudgeProductName == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(
        stockNudgeProductId: null,
        stockNudgeProductName: null,
      ),
    );
  }

  Future<void> _setStockNudgeIfNeeded(List<OrderLineItem> draftLineItems) async {
    final String? firstProductId = draftLineItems
        .map((OrderLineItem item) => item.productId)
        .whereType<String>()
        .firstOrNull;

    if (firstProductId == null || firstProductId.trim().isEmpty) {
      return;
    }

    final List<dynamic> products = await ref.read(catalogueProductsProvider.future);
    dynamic selected;
    for (final dynamic product in products) {
      if ((product.id as String?) == firstProductId) {
        selected = product;
        break;
      }
    }

    if (selected == null) {
      return;
    }

    final int? quantity = selected.quantity as int?;
    if (quantity == null) {
      return;
    }

    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    state = AsyncData(
      current.copyWith(
        stockNudgeProductId: firstProductId,
        stockNudgeProductName: selected.name as String?,
      ),
    );
  }

  Future<String> _uploadSlipImage({
    required String userId,
    required String slipId,
    required Uint8List imageBytes,
  }) async {
    final String path = 'order-slips/${userId.trim()}/${slipId.trim()}.jpg';
    final dynamic ref = FirebaseService.store.ref().child(path);

    await ref.putData(
      imageBytes,
      <String, Object>{'contentType': 'image/jpeg'},
    );

    final dynamic downloadUrl = await ref.getDownloadURL();
    if (downloadUrl is String && downloadUrl.trim().isNotEmpty) {
      return downloadUrl;
    }

    return path;
  }

  void _replaceSlipInState(OrderSlip slip, {required bool isGeneratingImage}) {
    final OrderSlipState current = state.asData?.value ?? const OrderSlipState();
    final List<OrderSlip> updated = current.slips
        .map((OrderSlip currentSlip) => currentSlip.id == slip.id ? slip : currentSlip)
        .toList(growable: false);

    state = AsyncData(
      current.copyWith(
        slips: updated,
        latestCreatedSlip: slip,
        isGeneratingImage: isGeneratingImage,
      ),
    );
  }

  String _buildVariantLabel(List<dynamic> variantGroups) {
    if (variantGroups.isEmpty) {
      return '';
    }

    final List<String> chunks = <String>[];
    for (final dynamic group in variantGroups) {
      final String name = (group.name as String?)?.trim() ?? '';
      final List<dynamic> rawOptions = group.options as List<dynamic>? ?? <dynamic>[];
      final List<String> options = rawOptions
          .map((dynamic option) => option.toString().trim())
          .where((String value) => value.isNotEmpty)
          .toList(growable: false);
      if (name.isEmpty || options.isEmpty) {
        continue;
      }
      chunks.add('$name: ${options.join('/')}');
    }

    return chunks.join(', ');
  }
}

@riverpod
int currentMonthOrderCount(Ref ref) {
  final AsyncValue<OrderSlipState> state = ref.watch(orderSlipProvider);
  final List<OrderSlip> slips = state.asData?.value.slips ?? const <OrderSlip>[];

  final DateTime now = DateTime.now();
  return slips.where((OrderSlip slip) {
    return slip.createdAt.year == now.year && slip.createdAt.month == now.month;
  }).length;
}

@riverpod
OrderSlip? orderSlipById(Ref ref, String slipId) {
  final AsyncValue<OrderSlipState> state = ref.watch(orderSlipProvider);
  final List<OrderSlip> slips = state.asData?.value.slips ?? const <OrderSlip>[];

  for (final OrderSlip slip in slips) {
    if (slip.id == slipId) {
      return slip;
    }
  }

  return null;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String? _nullableTrim(String? value) {
  final String cleaned = (value ?? '').trim();
  if (cleaned.isEmpty) {
    return null;
  }
  return cleaned;
}

String? _toIndianPhoneOrNull(String? value) {
  final String raw = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (raw.isEmpty) {
    return null;
  }

  if (raw.length == 12 && raw.startsWith('91')) {
    return raw;
  }

  if (raw.length >= 10) {
    final String lastTen = raw.substring(raw.length - 10);
    return '91$lastTen';
  }

  return null;
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
