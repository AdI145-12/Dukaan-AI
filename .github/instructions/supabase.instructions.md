---
applyTo: "supabase/**"
---

# Supabase Instructions (supabase/**)

## Exact Table Names (Do Not Invent New Ones)
```
profiles          — user profiles (extends auth.users)
generated_ads     — AI-generated ad outputs
khata_entries     — customer credit ledger
transactions      — payment transaction records
usage_events      — analytics event log
```

## Exact Column Names Per Table

### profiles
id, shop_name, owner_name, phone, city, business_category,
tier (free|dukaan|vyapaar|utsav), credits_remaining, created_at, updated_at

### generated_ads
id, user_id, image_url, caption, hashtags (text[]), style_used,
product_name, is_watermarked (bool), created_at

### khata_entries
id, user_id, customer_name, customer_phone, amount_owed (numeric),
notes, last_updated, created_at

### transactions
id, user_id, amount (numeric), razorpay_payment_id, plan,
credits_purchased (int), status (pending|success|failed), created_at

### usage_events
id, user_id, event_type (text), metadata (jsonb), created_at

## Migration File Rules
- File naming: `YYYYMMDDHHMMSS_descriptive_name.sql`
- Always include: `-- Migration: <name>` comment at top
- Every migration must be idempotent: use `IF NOT EXISTS`, `IF EXISTS`
- Always include rollback SQL in a comment block at the bottom

## RLS Policy Pattern (Required on Every Table)
```sql
-- Enable RLS
ALTER TABLE public.<table_name> ENABLE ROW LEVEL SECURITY;

-- Users can only access their own rows
CREATE POLICY "Users can view own rows" ON public.<table_name>
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own rows" ON public.<table_name>
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own rows" ON public.<table_name>
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own rows" ON public.<table_name>
  FOR DELETE USING (auth.uid() = user_id);
```

## Supabase Edge Functions (Deno)
- Runtime: Deno (not Node.js) — use Deno-compatible imports
- Secrets: use `Deno.env.get('VARIABLE_NAME')` — never hardcode
- Always handle CORS in Edge Functions (same pattern as Workers)
- Use `supabaseAdmin` (service key) not `supabaseClient` (anon) for privileged operations

## Performance Rules
- Always add index on `user_id` for every table
- Add index on `created_at` for tables queried by date
- Never use `SELECT *` — always name columns
- Paginate all list queries: `.range(from, to)` with max 20 rows per page
- Use `.order('created_at', { ascending: false })` as default sort

## Naming Conventions
- Functions: `snake_case` (e.g., `decrement_credits`, `get_user_stats`)
- Tables: `snake_case` plural (e.g., `generated_ads`, `khata_entries`)
- Indexes: `idx_<table>_<column>` (e.g., `idx_generated_ads_user_id`)
- Policies: descriptive English sentence (e.g., `"Users can view own rows"`)
