---
name: supabase-schema
description: >
  Use this skill whenever writing Supabase queries, RLS policies, SQL migrations,
  or repository implementations that touch the database. Contains the exact table
  names, column names, RLS rules, and query patterns for the Dukaan AI database.
  Always consult this before writing any Supabase query.
---

# Dukaan AI — Supabase Schema Reference

## Supabase Client Access

```dart
// Always use the singleton — never create a new SupabaseClient
import 'package:dukaan_ai/core/supabase/supabase_client.dart';
final client = SupabaseClient.instance; // → supabase.from(...)
```

## Table Reference (Use ONLY These Names)

Use `SupabaseTables.<name>` constants in code. Raw values listed for SQL:

| Constant | Raw Table Name | Purpose |
|---|---|---|
| `SupabaseTables.profiles` | `profiles` | User profile, tier, credits |
| `SupabaseTables.generatedAds` | `generated_ads` | AI-generated ad images |
| `SupabaseTables.khataEntries` | `khata_entries` | Credit ledger entries |
| `SupabaseTables.transactions` | `transactions` | Payment history |
| `SupabaseTables.usageEvents` | `usage_events` | Credit usage tracking |
| `SupabaseTables.catalogues` | `catalogues` | Product catalogues |
| `SupabaseTables.catalogueProducts` | `catalogue_products` | Products inside catalogues |

## Column Reference

**profiles**
- `id` UUID PK (= auth.uid())
- `shop_name` TEXT NOT NULL
- `category` TEXT (kiryana/clothing/electronics/food/other)
- `city` TEXT
- `phone` TEXT UNIQUE
- `tier` TEXT DEFAULT 'free' (free/dukaan/vyapaar/utsav)
- `credits_remaining` INTEGER DEFAULT 3
- `fcm_token` TEXT
- `language` TEXT DEFAULT 'hinglish'
- `created_at` TIMESTAMPTZ

**generated_ads**
- `id` UUID PK
- `user_id` UUID FK → profiles.id
- `image_url` TEXT (Supabase Storage URL)
- `thumbnail_url` TEXT
- `background_style` TEXT
- `caption_hindi` TEXT
- `caption_english` TEXT
- `share_count` INTEGER DEFAULT 0
- `download_count` INTEGER DEFAULT 0
- `festival_tag` TEXT NULLABLE
- `created_at` TIMESTAMPTZ

**khata_entries**
- `id` UUID PK
- `user_id` UUID FK → profiles.id
- `customer_name` TEXT NOT NULL
- `customer_phone` TEXT
- `amount` NUMERIC(10,2) NOT NULL
- `type` TEXT (credit/debit)
- `note` TEXT
- `is_settled` BOOLEAN DEFAULT false
- `created_at` TIMESTAMPTZ

**transactions**
- `id` UUID PK
- `user_id` UUID FK → profiles.id
- `razorpay_order_id` TEXT UNIQUE
- `razorpay_payment_id` TEXT
- `plan_id` TEXT
- `amount_paise` INTEGER
- `status` TEXT (pending/success/failed)
- `credits_granted` INTEGER DEFAULT 0
- `created_at` TIMESTAMPTZ

**usage_events**
- `id` UUID PK
- `user_id` UUID FK → profiles.id
- `event_type` TEXT (ad_generated/catalogue_created)
- `credits_used` INTEGER DEFAULT 1
- `metadata` JSONB
- `created_at` TIMESTAMPTZ

## Standard Query Patterns

### Get current user profile
```dart
final profile = await client
  .from(SupabaseTables.profiles)
  .select()
  .eq(SupabaseColumns.id, client.auth.currentUser!.id)
  .single();
```

### Paginated ads query
```dart
final ads = await client
  .from(SupabaseTables.generatedAds)
  .select()
  .eq(SupabaseColumns.userId, userId)
  .order(SupabaseColumns.createdAt, ascending: false)
  .range(page * pageSize, (page + 1) * pageSize - 1);
```

### Realtime stream (for Khata)
```dart
final stream = client
  .from(SupabaseTables.khataEntries)
  .stream(primaryKey: ['id'])
  .eq(SupabaseColumns.userId, userId)
  .order(SupabaseColumns.createdAt, ascending: false);
```

### Atomic credit decrement (via RPC)
```dart
await client.rpc('decrement_credits', params: {
  'user_id': userId,
  'amount': 1,
});
// This calls the DB function — never UPDATE credits directly from client
```

## RLS Rules (Never Bypass These)

Every table has Row Level Security enabled. The universal rules are:
1. `SELECT`: `auth.uid() = user_id` — users see only their own data
2. `INSERT`: `auth.uid() = user_id` — users insert only for themselves
3. `UPDATE`: `auth.uid() = user_id` — users update only their own rows
4. `DELETE`: `auth.uid() = user_id` (where applicable)
5. **Service role** (Workers/Edge Functions only) can bypass RLS — never expose service key to Flutter

## Storage Buckets

| Bucket | Path Pattern | Access |
|---|---|---|
| `ad-images` | `{user_id}/{ad_id}.jpg` | Private — signed URLs only |
| `catalogue-images` | `{user_id}/{catalogue_id}/{product_id}.jpg` | Private |
| `ad-thumbnails` | `{user_id}/{ad_id}_thumb.jpg` | Public |

```dart
// Generate signed URL for private asset
final signedUrl = await client.storage
  .from('ad-images')
  .createSignedUrl('$userId/$adId.jpg', 3600); // 1 hour expiry
```

## Migration File Naming Convention

`YYYYMMDDHHMMSS_description.sql` — always timestamp-prefixed, never edit existing migrations.

## Copilot Rules for This Project

1. **Use SupabaseTables.x constants** — never hardcode 'profiles' as a string in Dart
2. **Use SupabaseColumns.x constants** — never hardcode 'user_id' as a string in Dart  
3. **Use RPC for credit operations** — never direct UPDATE on credits_remaining from Flutter
4. **Always use .single() for known single-row returns** — avoids returning a List<Map> when you expect one row
5. **Never use the service key in Flutter** — only in Workers/Edge Functions
6. **Realtime = .stream()** — use for khata_entries; use .select() for one-time fetches
7. **Error handling**: Supabase throws `PostgrestException` — catch and pass to `ErrorHandler.fromPostgrest(e)`
