export interface StoreShop {
  userId: string;
  shopName: string;
  slug: string;
  city?: string;
  storeBannerUrl?: string;
  storeDescription?: string;
  phone?: string;
  storeViewsCount: number;
  storeWhatsappClicks: number;
}

export interface StoreProduct {
  id: string;
  name: string;
  price: number;
  stockStatus: 'inStock' | 'lowStock';
  imageUrl?: string;
  description?: string;
  category?: string;
}

export interface StorePageData {
  shop: StoreShop;
  products: StoreProduct[];
}
