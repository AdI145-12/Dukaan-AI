import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockStatusHelper', () {
    test('stockStatusFromString returns inStock for inStock', () {
      expect(
        StockStatusHelper.stockStatusFromString('inStock'),
        StockStatus.inStock,
      );
    });

    test('stockStatusFromString returns lowStock for lowStock', () {
      expect(
        StockStatusHelper.stockStatusFromString('lowStock'),
        StockStatus.lowStock,
      );
    });

    test('stockStatusFromString returns outOfStock for outOfStock', () {
      expect(
        StockStatusHelper.stockStatusFromString('outOfStock'),
        StockStatus.outOfStock,
      );
    });

    test('stockStatusFromString returns inStock for null', () {
      expect(
        StockStatusHelper.stockStatusFromString(null),
        StockStatus.inStock,
      );
    });

    test('stockStatusFromString returns inStock for unknown value', () {
      expect(
        StockStatusHelper.stockStatusFromString('UNKNOWN_VALUE'),
        StockStatus.inStock,
      );
    });

    test('stockStatusToString roundtrips all statuses', () {
      for (final StockStatus status in StockStatus.values) {
        final String raw = StockStatusHelper.stockStatusToString(status);
        final StockStatus parsed = StockStatusHelper.stockStatusFromString(raw);
        expect(parsed, status);
      }
    });

    test('stockStatusLabel returns expected Hinglish labels', () {
      expect(
        StockStatusHelper.stockStatusLabel(StockStatus.inStock),
        'In Stock',
      );
      expect(
        StockStatusHelper.stockStatusLabel(StockStatus.lowStock),
        'Stock Kam Hai',
      );
      expect(
        StockStatusHelper.stockStatusLabel(StockStatus.outOfStock),
        'Out of Stock',
      );
    });

    test('stockStatusColor returns semantic keys', () {
      expect(
        StockStatusHelper.stockStatusColor(StockStatus.inStock),
        'success',
      );
      expect(
        StockStatusHelper.stockStatusColor(StockStatus.lowStock),
        'warning',
      );
      expect(
        StockStatusHelper.stockStatusColor(StockStatus.outOfStock),
        'error',
      );
    });
  });
}
