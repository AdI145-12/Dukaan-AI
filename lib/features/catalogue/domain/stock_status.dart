enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}

class StockStatusHelper {
  const StockStatusHelper._();

  static StockStatus stockStatusFromString(String? raw) {
    switch ((raw ?? '').trim()) {
      case 'inStock':
        return StockStatus.inStock;
      case 'lowStock':
        return StockStatus.lowStock;
      case 'outOfStock':
        return StockStatus.outOfStock;
      default:
        return StockStatus.inStock;
    }
  }

  static String stockStatusToString(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return 'inStock';
      case StockStatus.lowStock:
        return 'lowStock';
      case StockStatus.outOfStock:
        return 'outOfStock';
    }
  }

  static String stockStatusLabel(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Stock Kam Hai';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  static String stockStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return 'success';
      case StockStatus.lowStock:
        return 'warning';
      case StockStatus.outOfStock:
        return 'error';
    }
  }
}
