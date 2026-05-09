import type { Env } from '../types/env';
import type { StorePageData, StoreProduct, StoreShop } from '../types/store_page';
import {
  firestoreIncrement,
  firestoreQuery,
  intVal,
  numVal,
  strVal,
  type FirestoreFilter,
  type FirestoreQueryResult,
} from '../utils/firestore_admin';

const PROFILES_COLLECTION = 'profiles';
const PRODUCTS_COLLECTION = 'products';

export async function fetchStoreData(slug: string, env: Env): Promise<StorePageData | null> {
  try {
    const profileFilters: FirestoreFilter[] = [
      {
        field: { fieldPath: 'storeSlug' },
        op: 'EQUAL',
        value: { stringValue: slug },
      },
      {
        field: { fieldPath: 'storeIsPublished' },
        op: 'EQUAL',
        value: { booleanValue: true },
      },
    ];

    const profiles = await firestoreQuery(
      PROFILES_COLLECTION,
      profileFilters,
      1,
      env,
    );
    if (profiles.length === 0) {
      return null;
    }

    const profile = profiles[0] as FirestoreQueryResult;
    const userId = profile.id.trim();
    if (!userId) {
      return null;
    }

    const shop: StoreShop = {
      userId,
      shopName: strVal(profile.fields, 'shopName') ?? 'Meri Dukaan',
      slug,
      city: strVal(profile.fields, 'city') ?? undefined,
      storeBannerUrl: strVal(profile.fields, 'storeBannerUrl') ?? undefined,
      storeDescription: strVal(profile.fields, 'storeDescription') ?? undefined,
      phone: strVal(profile.fields, 'phone') ?? undefined,
      storeViewsCount: intVal(profile.fields, 'storeViewsCount'),
      storeWhatsappClicks: intVal(profile.fields, 'storeWhatsappClicks'),
    };

    const productFilters: FirestoreFilter[] = [
      {
        field: { fieldPath: 'userId' },
        op: 'EQUAL',
        value: { stringValue: userId },
      },
      {
        field: { fieldPath: 'isVisible' },
        op: 'EQUAL',
        value: { booleanValue: true },
      },
    ];

    const productRows = await firestoreQuery(
      PRODUCTS_COLLECTION,
      productFilters,
      50,
      env,
    );

    const products: StoreProduct[] = productRows
      .map((product): StoreProduct | null => {
        const stockStatus = strVal(product.fields, 'stockStatus') ?? 'inStock';
        if (stockStatus !== 'inStock' && stockStatus !== 'lowStock') {
          return null;
        }

        const id = product.id.trim();
        const name = (strVal(product.fields, 'name') ?? '').trim();
        if (!id || !name) {
          return null;
        }

        const mapped: StoreProduct = {
          id,
          name,
          price: numVal(product.fields, 'price'),
          stockStatus,
        };

        const imageUrl = strVal(product.fields, 'imageUrl');
        if (imageUrl) {
          mapped.imageUrl = imageUrl;
        }

        const description = strVal(product.fields, 'description');
        if (description) {
          mapped.description = description;
        }

        const category = strVal(product.fields, 'category');
        if (category) {
          mapped.category = category;
        }

        return mapped;
      })
      .filter((item): item is StoreProduct => item !== null);

    return {
      shop,
      products,
    };
  } catch (error) {
    console.error('store-page: fetch-store-data-error', error);
    return null;
  }
}

export async function incrementViewCount(userId: string, env: Env): Promise<void> {
  if (!userId.trim()) {
    return;
  }

  try {
    await firestoreIncrement(`profiles/${userId}`, 'storeViewsCount', 1, env);
  } catch (error) {
    console.error('store-page: increment-views-error', error);
  }
}

export async function incrementClickCount(slug: string, env: Env): Promise<void> {
  if (!slug.trim()) {
    return;
  }

  try {
    const profileRows = await firestoreQuery(
      PROFILES_COLLECTION,
      [
        {
          field: { fieldPath: 'storeSlug' },
          op: 'EQUAL',
          value: { stringValue: slug },
        },
      ],
      1,
      env,
    );

    if (profileRows.length === 0) {
      return;
    }

    const userId = profileRows[0].id.trim();
    if (!userId) {
      return;
    }

    await firestoreIncrement(
      `profiles/${userId}`,
      'storeWhatsappClicks',
      1,
      env,
    );
  } catch (error) {
    console.error('store-page: increment-clicks-error', error);
  }
}

export async function incrementWhatsappClicksBySlug(
  slug: string,
  env: Env,
): Promise<void> {
  await incrementClickCount(slug, env);
}
