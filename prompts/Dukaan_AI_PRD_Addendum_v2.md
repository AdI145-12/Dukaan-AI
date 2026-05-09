# Dukaan AI — PRD Addendum v2.0
**Document Version:** 2.0  
**Created:** April 07, 2026  
**Status:** Strategic Expansion — Seller Operating System  
**Extends:** Dukaan AI PRD v1.0 (March 30, 2026)

---

## Executive Summary (Updated Vision)

Dukaan AI is evolving from an AI creative tool into the **daily command center for Indian small sellers**. The core v1.0 product (Studio, Khata, Broadcast) established the marketing and payment foundation. This addendum defines the next strategic layer: **10 high-impact features that transform Dukaan AI into a true Seller Operating System (Seller OS)**.

> **The Moat Is Not AI. The Moat Is Workflow Lock-In.**

A seller who stores their catalog, tracks inquiries, runs follow-ups, and checks daily insights inside Dukaan AI is structurally retained. The goal shifts from "useful tool" to "business infrastructure."

---

## Updated Problem Statement — The 7 Real Pain Clusters

The semi-digital Indian seller (WhatsApp/Instagram/Meesho, non-professional, wants more orders) suffers across 7 specific pain loops. These directly map to the 10 features below.

| # | Pain (In Their Words) | Feature That Solves It |
|---|---|---|
| 1 | "Mere products acche hain, but dikhte acche nahi" | Studio (v1.0 — already live) |
| 2 | "Mujhe roz kya post karna hai, samajh nahi aata" | Daily Content Planner |
| 3 | "Customers DM karte hain, but sales process messy hai" | Lead / Inquiry Tracker (Mini CRM) |
| 4 | "Inventory / price / stock manage karna messy hai" | Smart Product Catalog + Stock Tracking |
| 5 | "Customers poochte rehte hain same cheezein" | FAQ / Quick Reply Kit |
| 6 | "Payment aur udhaar track nahi hota" | Khata (v1.0) + Order Slip Generator |
| 7 | "Repeat sales nahi aa rahi" | Auto Follow-Up & Broadcast Engine |

---

## Strategic Product Evolution — 3 Phases

```
Phase 1 — SELL BETTER (v1.0 — DONE)
  ✅ AI product photos
  ✅ Hindi/Hinglish captions
  ✅ Festival banners
  ✅ WhatsApp sharing

Phase 2 — MANAGE BETTER (v2.0 — This Addendum)
  🔲 Smart Product Catalog Builder
  🔲 Lead / Inquiry Tracker
  🔲 Simple Inventory + Stock Tracking
  🔲 FAQ / Quick Reply Kit
  🔲 Quote / Invoice / Order Slip Generator

Phase 3 — GROW BETTER (v3.0 — Future)
  🔲 Daily Content Planner Engine
  🔲 One-Tap Seller Store / Shareable Page
  🔲 Auto Follow-Up & Broadcast Engine
  🔲 Festival / Season Sales Packs (expanded)
  🔲 Best Seller / Sales Insight Dashboard
```

**Build Sequence Rationale:**  
Phase 2 features create data lock-in (products, inquiries, stock). Phase 3 features leverage that data to drive revenue (follow-ups, storefront, insights). Never build Phase 3 before Phase 2 — you need the data layer first.

---

## Feature Specifications — Phase 2 (v2.0)

---

### FEATURE S1 — Smart Product Catalog Builder

**Priority:** 🔥 #1 Strategic Feature  
**Phase:** 2 — Manage Better  
**Plan Tier:** Vyapaar (₹249) and above

#### Problem It Solves
Sellers have random gallery photos, scattered WhatsApp images, no organized product list, and no ready-to-share catalog. Every time a customer asks "kya hai aapke paas?" the seller scrambles.

#### User Flow
1. Tap **"Catalog"** tab → **"Add Product"**
2. Input: Product name, price, category, variants (size/color), stock status, product image (from camera or gallery), description (optional, AI can auto-generate)
3. Product saved to Supabase `products` table
4. Catalog auto-generates a **shareable product card** (uses Studio engine for background)
5. Seller can share individual product cards or full catalog link

#### Feature Capabilities
- Add unlimited products (Vyapaar+), 20 products (Dukaan), 5 (Free)
- Per-product: name, price, category, variants (size/color chips), stock status (In Stock / Low / Out), product image, AI-generated description
- One-tap **"Create Ad from Product"** → pre-fills Studio with product image
- Product cards shareable directly to WhatsApp (no re-upload needed)
- Search and filter products within the app

#### Technical Requirements
- **New Supabase table:** `products` (see Schema section)
- **New Cloudflare Worker endpoint:** `POST /api/generate-product-description` (GPT-4o-mini)
- Image stored in Supabase Storage bucket `product-images`
- Product card generation reuses existing Studio background engine
- Offline support: products cached locally via `shared_preferences` for read; writes sync when online

#### Why This Is the Foundation
Once 50+ products live inside Dukaan AI, the seller's switching cost becomes very high. Every other feature (follow-ups, store page, content planner) becomes more powerful when product data exists.

#### Success Metrics
- 30% of Vyapaar users add 10+ products within 7 days of feature launch
- Product-to-ad creation rate: 40% (users who add a product, then create an ad from it)

---

### FEATURE S2 — Lead / Inquiry Tracker (Mini CRM)

**Priority:** 🔥 #2 Strategic Feature  
**Phase:** 2 — Manage Better  
**Plan Tier:** Vyapaar (₹249) and above

#### Problem It Solves
Sellers receive inquiries via WhatsApp and Instagram DMs but forget them. They have no system for "kisne poocha tha, kisko follow-up karna hai?" This directly causes lost revenue.

#### User Flow
1. Tap **"Inquiries"** tab (new tab) or from **Catalog > product > "Track Inquiry"**
2. Add inquiry manually: customer name, phone, product asked, source (WhatsApp/Instagram/Offline/Other)
3. Set inquiry status: `New` → `Interested` → `Payment Pending` → `Ordered` → `Delivered` → `Follow-Up Needed`
4. App shows **"Aaj follow-up karo"** list — all inquiries with status `Follow-Up Needed` or `Interested` older than 2 days
5. One-tap **"WhatsApp Follow-Up"** opens WhatsApp with pre-drafted message: *"Namaste [Name] ji! Aapne [Product] ke baare mein poocha tha. Abhi available hai. Lena hai kya? 😊"*

#### Feature Capabilities
- List view with status color-coding (green = ordered, yellow = pending, red = needs follow-up)
- Quick status update swipe right to advance, swipe left to mark follow-up
- Filter by status, date, product
- Inquiry count badge on tab icon (follow-ups pending)
- Link inquiry to a product from the Catalog

#### Technical Requirements
- **New Supabase table:** `inquiries` (see Schema section)
- No Cloudflare Worker needed — all CRUD via Supabase Flutter SDK
- Realtime updates via Supabase Realtime subscription
- Local notification: daily 6 PM reminder if `follow_up_needed_count > 0`: *"Aapke X customers follow-up ka wait kar rahe hain!"*

#### Success Metrics
- D14 retention of users who add 3+ inquiries: target 65% (vs 40% baseline)
- WhatsApp follow-up taps per active user per week: target 5+

---

### FEATURE S3 — Simple Inventory + Stock Tracking

**Priority:** 🔥 #3 (Companion to Catalog)  
**Phase:** 2 — Manage Better  
**Plan Tier:** Dukaan (₹99) and above

#### Problem It Solves
Sellers don't know what's in stock, what's sold, or what to quote. When a customer asks "available hai?" and the seller isn't sure, trust breaks and sales are lost.

#### User Flow
1. Inside each product in Catalog, stock status is one of: **In Stock** / **Low Stock** / **Out of Stock**
2. Seller can set quantity (optional — just a number field, not complex)
3. When seller marks a product **Out of Stock**, it auto-removes from the Seller Store (Feature G1)
4. **Restock reminder**: if a product has been Out of Stock for 7+ days, app sends notification: *"[Product] 7 din se out of stock hai. Restock karein?"*
5. **Low Stock Alert**: if quantity drops below user-defined threshold (default: 3), badge appears on product card

#### Feature Capabilities
- Visual stock badges on product cards (green dot, yellow dot, red dot)
- Bulk stock update (mark multiple as restocked)
- "What's selling" insight: most-inquired vs in-stock/out-of-stock comparison (feeds into Insight Dashboard)
- Stock history is NOT required in v2.0 — keep it lightweight

#### Technical Requirements
- Stock data lives in `products` table columns: `stock_status ENUM`, `quantity INT nullable`
- No new Cloudflare Worker needed
- Local FCM notification scheduled via Cloudflare Cron (restock reminders, weekly batch)

---

### FEATURE S4 — FAQ / Quick Reply Kit

**Priority:** 🔥 #4 — Retention Feature  
**Phase:** 2 — Manage Better  
**Plan Tier:** Dukaan (₹99) and above

#### Problem It Solves
Sellers answer the same WhatsApp questions every single day: price, COD, delivery, size, payment method, location. This wastes 30-60 minutes daily and leads to frustration and inconsistent responses.

#### User Flow
1. **"Quick Replies"** section in Account tab → pre-populated with common templates
2. Default templates cover: Price, COD Policy, Delivery Time, Size/Color, Payment Methods, Location/Address, Custom Order, Return Policy
3. Seller can edit any template with their actual shop info
4. **Share button** on each reply: opens WhatsApp with reply pre-filled
5. Seller can **add custom replies** (e.g., "Aaj ka offer" or "Wholesale rate")
6. From Studio home's Quick Create, a shortcut: **"Copy Quick Reply"** shows the reply list for instant copy

#### Feature Capabilities
- 8 default templates (Hinglish, editable)
- Up to 20 custom replies (Vyapaar+), 10 (Dukaan)
- Tags: tag replies (e.g., "pricing", "delivery", "offers") for quick filtering
- One-tap copy to clipboard with SnackBar confirmation: *"Copy ho gaya!"*
- One-tap WhatsApp share

#### Technical Requirements
- **New Supabase table:** `quick_replies` (see Schema section)
- Default templates seeded on first app install via `seed_default_replies()` Supabase RPC
- No Cloudflare Worker needed for CRUD
- Optional (Phase 3): AI suggests a reply based on customer's WhatsApp message text (paste and get suggestion)

---

### FEATURE S5 — Quote / Invoice / Order Slip Generator

**Priority:** 🔥 #5 — Professionalism Feature  
**Phase:** 2 — Manage Better  
**Plan Tier:** Vyapaar (₹249) and above

#### Problem It Solves
When a sale happens, sellers manually type out totals and confirmations in WhatsApp. It looks unprofessional and often leads to disputes about what was ordered and at what price.

#### User Flow
1. **"New Order Slip"** button in Inquiries tab (after marking inquiry as "Ordered") or standalone from Account menu
2. Fill in: Customer name, products selected from Catalog (auto-pulls price), quantity, discount (optional), delivery charges (optional), payment mode (UPI/Cash/COD/Pending)
3. App generates a **branded order slip card** with shop name, logo, product list, total, and payment QR code
4. Seller shares slip to customer via WhatsApp — *"Ye aapka order confirmation hai"*
5. Optional: Add delivery note or expected delivery date

#### Feature Capabilities
- Order slip is a shareable image (PNG) — same format as ad cards, using Studio rendering
- Branded with seller's shop name and logo
- Auto-calculates totals including discounts
- GST field (optional — toggle off by default for non-GST sellers)
- Saved to "Orders" section in app for reference
- One-tap UPI payment link appended to slip (via existing `upiutils.dart`)

#### Technical Requirements
- **New Supabase table:** `order_slips` (see Schema section)
- **New Cloudflare Worker endpoint:** `POST /api/generate-order-slip-image` — renders order slip as PNG (uses Canvas/Puppeteer or server-side HTML-to-image)
- Links to `products` table for auto-price-fill
- Links to `inquiries` table for one-click "convert inquiry to order"

---

## Feature Specifications — Phase 3 (v3.0 Roadmap)

---

### FEATURE G1 — Daily Content Planner ("Aaj Kya Post Karu?" Engine)

**Priority:** 🔥 Extremely Sticky  
**Phase:** 3 — Grow Better  
**Plan Tier:** Vyapaar (₹249) and above

#### Problem It Solves
Decision fatigue. Sellers know they should post daily but don't know *what* to post today. This leads to posting nothing, which kills reach.

#### What It Does
Every morning (configurable time, default 9 AM), the app surfaces a **"Today's Plan"** card on the Studio home screen showing:
- **WhatsApp Status idea** for today (e.g., "Aaj Sunday hai — combo offer status banao")
- **Instagram Post suggestion** (e.g., "Festive season starting — highlight your top product")
- **Offer banner idea** if relevant festival/season is approaching
- **"Best product to promote today"** — pulled from Catalog (most-inquired, restocked, or seasonal)

#### Intelligence Layer
- Checks Indian festival calendar (existing `festivalcalendar.dart`)
- Checks day of week patterns (Mondays = new arrivals, Fridays = weekend offers, Sundays = combo deals)
- Checks seller's most popular products from Catalog
- Checks season (wedding season, summer, back-to-school, etc.)

#### User Flow
1. Open app → Studio home shows **"Aaj ka Plan"** card (dismissible)
2. Each suggestion has a **"Banao"** (Create) button → pre-loads Studio with relevant template/product
3. Seller completes and shares in < 2 minutes
4. Completion streak shown: *"5 din se post kar rahe ho! 🔥"*

#### Technical Requirements
- **New Cloudflare Worker endpoint:** `POST /api/get-daily-plan` — takes user's category, location (optional), today's date; returns JSON plan
- Uses GPT-4o-mini with a prompt seeded with festival calendar + seller category
- Results cached per user per day in Cloudflare KV (don't regenerate if already fetched today)
- Streak tracked in `usage_events` table

---

### FEATURE G2 — One-Tap Seller Store / Shareable Product Page

**Priority:** 🔥 #4 Overall  
**Phase:** 3 — Grow Better  
**Plan Tier:** Vyapaar (₹249) and above

#### Problem It Solves
Sellers have no storefront. They sell by sending 20+ photos manually to each customer. A shareable store link would replace this entirely.

#### What It Does
Auto-generates a **mobile-first mini store page** from the seller's Catalog:
- URL format: `prachar.app/shop/[username]` (or `dukaan.ai/s/[username]`)
- Page shows: shop name, logo, banner, product grid with prices, WhatsApp order button, UPI QR code
- Only "In Stock" products are shown (respects Inventory status)
- Customer taps a product → sees product card + **"WhatsApp pe order karein"** button
- Seller shares their store link everywhere: WhatsApp bio, Instagram bio, visiting card QR

#### Technical Requirements
- Store page is a **server-rendered web page** hosted on Cloudflare Pages (or Workers + HTML)
- Reads from Supabase `products` + `shops` tables via public read-only API
- No login required for customers to browse
- **New Supabase column:** `shops.store_slug TEXT UNIQUE` — seller sets their URL slug during onboarding (v2.0 adds this field)
- Store page auto-updates when seller adds/removes products
- Analytics: view count, WhatsApp click count tracked per store page

---

### FEATURE G3 — Auto Follow-Up & Broadcast Engine

**Priority:** 🔥 #5 Overall — Direct Revenue Driver  
**Phase:** 3 — Grow Better  
**Plan Tier:** Utsav (₹499) only

#### Problem It Solves
Sellers get first orders but lose customers because they never follow up. The money is in re-engagement, not new acquisition.

#### What It Does
Seller creates **broadcast campaigns** to:
- All past customers (from Khata + Inquiries)
- Customers who inquired but didn't order
- Customers who ordered a specific product category
- Festival-triggered: auto-suggest campaign before Diwali, Eid, etc.

#### Message Templates (AI-Generated, Seller-Editable)
- New arrivals: *"[Name] ji, naya stock aa gaya! Aapka favorite [category] dekhein 👉 [Store Link]"*
- Restock alert: *"[Product] wapas aa gaya! Jaldi order karein — limited stock hai 🔥"*
- Festival offer: *"Diwali offer sirf aapke liye: [offer]. Aaj order karein!"*
- Re-engagement: *"Bahut din ho gaye aapko miss kar rahe hain. Kuch naya dekhein?"*

#### Technical Requirements
- **New Supabase table:** `broadcast_campaigns` (see Schema section)
- **New Cloudflare Worker endpoint:** `POST /api/send-broadcast` — sends WhatsApp messages via MessageBird/Twilio in batches
- Rate limiting: max 500 messages/day per seller to comply with WhatsApp Business API policies
- Delivery status tracking: sent, delivered, failed per recipient
- Unsubscribe handling: customers who reply "STOP" are flagged in `customers` table

---

### FEATURE G4 — Best Seller / Sales Insight Dashboard

**Priority:** Good for premium feel  
**Phase:** 3 — Grow Better  
**Plan Tier:** Utsav (₹499) only

#### Problem It Solves
Sellers don't know what's working. They guess which products to promote and which customers to chase.

#### What It Shows (Keep Simple — Action-Based, Not Chart-Heavy)
- **Most promoted product** (most Studio ads created from it)
- **Most inquired product** (from Inquiry Tracker)
- **Pending follow-ups count**
- **Repeat customer count** (customers with 2+ orders)
- **Pending payments total** (from Khata)
- **Top performing broadcast** (most WhatsApp link clicks)
- **This week vs last week**: ads created, inquiries received, orders confirmed

#### Design Rules
- NO complex charts — use simple number cards with arrows (up/down)
- Max 8 metrics on one screen
- Each metric has a **"Take Action"** button: e.g., "5 pending follow-ups → Go to Inquiries"
- Hindi/Hinglish labels throughout

#### Technical Requirements
- Data aggregated from existing tables: `generated_ads`, `inquiries`, `order_slips`, `khata_entries`, `broadcast_campaigns`
- Dashboard computed on Supabase side via a **Database View** or **RPC function** `get_seller_insights(user_id)`
- Refreshes daily (not real-time — saves compute)
- No new Cloudflare Worker needed

---

### FEATURE G5 — Enhanced Festival / Season Sales Packs

**Priority:** Strong India-Specific Differentiator  
**Phase:** 3 — Grow Better  
**Plan Tier:** All tiers (Free gets limited access)

#### What's New (Beyond v1.0 Festival Notifications)
v1.0 had festival push notifications → open Studio → make ad.  
v3.0 Festival Packs are **complete campaign kits**:

| Pack | Contents |
|------|----------|
| Diwali Pack | 10 banner templates + 5 WhatsApp status templates + 3 broadcast message drafts + product promotion checklist |
| Wedding Season Pack | 6 banner templates (jewelry/apparel focused) + customer reactivation messages + "last chance" offer templates |
| Summer Sale Pack | Offer banner templates + "clearance sale" broadcast + countdown status templates |
| Rakhi Pack | Gift-focused banners + *"Bhai ke liye kuch khaas?"* broadcast templates |
| Back to School Pack | Category-specific (stationery/bags/shoes) templates + offer formats |

#### Monetization Hook
- Base packs included in Vyapaar/Utsav plans
- **Premium Seasonal Packs** (₹49 one-time) available for major festivals: Diwali Mega Pack, IPL Pack, etc.
- Festival Pack bundle (₹199 for 7-day unlimited access) retained from v1.0 for Free/Dukaan users

---

## Database Schema — New Tables (Addendum to v1.0 Schema)

```sql
-- FEATURE S1: Smart Product Catalog
CREATE TABLE IF NOT EXISTS products (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  price         DECIMAL(10,2) NOT NULL,
  category      TEXT,
  description   TEXT,
  image_url     TEXT,
  variants      JSONB,           -- [{type: "size", options: ["S","M","L"]}]
  stock_status  TEXT DEFAULT 'in_stock' CHECK (stock_status IN ('in_stock','low_stock','out_of_stock')),
  quantity      INT,
  is_visible    BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own products" ON products FOR ALL USING (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_products_user_id ON products(user_id);
CREATE INDEX IF NOT EXISTS idx_products_stock_status ON products(stock_status);

-- FEATURE S2: Lead / Inquiry Tracker
CREATE TABLE IF NOT EXISTS inquiries (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  product_id    UUID REFERENCES products(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT,
  product_asked TEXT NOT NULL,
  source        TEXT DEFAULT 'whatsapp' CHECK (source IN ('whatsapp','instagram','offline','other')),
  status        TEXT DEFAULT 'new' CHECK (status IN ('new','interested','payment_pending','ordered','delivered','follow_up_needed')),
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own inquiries" ON inquiries FOR ALL USING (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_user_id ON inquiries(user_id);
CREATE INDEX IF NOT EXISTS idx_inquiries_status ON inquiries(status);

-- FEATURE S4: Quick Replies
CREATE TABLE IF NOT EXISTS quick_replies (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  tags        TEXT[],
  is_default  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE quick_replies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own replies" ON quick_replies FOR ALL USING (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_quick_replies_user_id ON quick_replies(user_id);

-- FEATURE S5: Order Slips
CREATE TABLE IF NOT EXISTS order_slips (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  inquiry_id      UUID REFERENCES inquiries(id) ON DELETE SET NULL,
  customer_name   TEXT NOT NULL,
  customer_phone  TEXT,
  line_items      JSONB NOT NULL,   -- [{product_id, name, price, qty, subtotal}]
  subtotal        DECIMAL(10,2) NOT NULL,
  discount        DECIMAL(10,2) DEFAULT 0,
  delivery_charge DECIMAL(10,2) DEFAULT 0,
  total           DECIMAL(10,2) NOT NULL,
  payment_mode    TEXT DEFAULT 'pending' CHECK (payment_mode IN ('upi','cash','cod','pending')),
  delivery_note   TEXT,
  slip_image_url  TEXT,
  gst_enabled     BOOLEAN DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE order_slips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own orders" ON order_slips FOR ALL USING (auth.uid() = user_id);
CREATE INDEX IF NOT EXISTS idx_order_slips_user_id ON order_slips(user_id);

-- FEATURE G3: Broadcast Campaigns
CREATE TABLE IF NOT EXISTS broadcast_campaigns (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  message_text    TEXT NOT NULL,
  media_url       TEXT,
  recipient_type  TEXT DEFAULT 'all' CHECK (recipient_type IN ('all','inquired','ordered','category')),
  status          TEXT DEFAULT 'draft' CHECK (status IN ('draft','sending','sent','failed')),
  sent_count      INT DEFAULT 0,
  delivered_count INT DEFAULT 0,
  failed_count    INT DEFAULT 0,
  scheduled_at    TIMESTAMPTZ,
  sent_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE broadcast_campaigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own campaigns" ON broadcast_campaigns FOR ALL USING (auth.uid() = user_id);

-- ADD to shops table (for Seller Store)
ALTER TABLE shops ADD COLUMN IF NOT EXISTS store_slug TEXT UNIQUE;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS store_banner_url TEXT;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS store_description TEXT;
ALTER TABLE shops ADD COLUMN IF NOT EXISTS store_views_count INT DEFAULT 0;
```

---

## New Cloudflare Worker Endpoints (Addendum)

| Endpoint | Method | Purpose | Rate Limit |
|---|---|---|---|
| `/api/generate-product-description` | POST | GPT-4o-mini generates product description from name + category | 20 req/user/day |
| `/api/generate-order-slip-image` | POST | Renders order slip as PNG (HTML-to-image) | 50 req/user/day |
| `/api/get-daily-plan` | POST | Returns today's content plan based on category + festivals | 1 req/user/day (KV cached) |
| `/api/send-broadcast` | POST | Sends WhatsApp broadcast to customer list in batches | 500 msgs/user/day |
| `/api/get-seller-store` | GET | Public endpoint — returns store products for seller store page | No auth required, 100 req/min |

---

## Updated Pricing Justification

The expanded feature set directly strengthens the ₹249–₹499 tier value proposition:

| Feature Added | Retention Impact | Pricing Tier |
|---|---|---|
| Smart Product Catalog | HIGH — data lock-in (50+ products) | Vyapaar ₹249 |
| Inquiry Tracker / CRM | HIGH — closes 3-5 extra orders/month | Vyapaar ₹249 |
| Stock Tracking | MEDIUM — operational necessity | Dukaan ₹99 |
| Quick Reply Kit | HIGH — daily use (saves 30 min/day) | Dukaan ₹99 |
| Order Slip Generator | MEDIUM — professionalism + trust | Vyapaar ₹249 |
| Daily Content Planner | VERY HIGH — daily habit creation | Vyapaar ₹249 |
| Seller Store Page | VERY HIGH — becomes sales channel | Vyapaar ₹249 |
| Auto Follow-Up Engine | VERY HIGH — direct repeat revenue | Utsav ₹499 |
| Insight Dashboard | MEDIUM — premium feel | Utsav ₹499 |
| Festival Packs Enhanced | HIGH — seasonal urgency | Vyapaar ₹249 |

**Net Pricing Impact:**  
With Phase 2 features live, ₹249/month Vyapaar becomes extremely defensible — a seller who uses Catalog + Inquiries + Quick Replies is getting >₹2,000/month value in time savings and recovered sales.

---

## Updated Competitive Moat Analysis

| Moat Type | How Dukaan AI Builds It |
|---|---|
| Data Lock-In | Products, Inquiries, Customer data stored in-app |
| Workflow Lock-In | Seller's daily routine (post, track, follow-up) depends on the app |
| Switching Cost | 100+ products, 500+ inquiries, 200+ customers — too expensive to migrate |
| Network Effect | Seller Store links shared everywhere create organic awareness |
| AI Personalization | Daily Plan becomes more personalized over time (better suggestions) |

> **The right answer to "why can't competitors copy this?" is not "our AI" — it's "our seller has 3 months of business data inside our app."**

---

## Updated Build Roadmap (Post v1.0)

| Week | Feature | Priority |
|---|---|---|
| Week 4-5 | Smart Product Catalog Builder (S1) | 🔥 Start here |
| Week 5-6 | Inventory / Stock Tracking (S3) | Companion to Catalog |
| Week 6-7 | Lead / Inquiry Tracker (S2) | 🔥 High retention |
| Week 7-8 | FAQ / Quick Reply Kit (S4) | Quick win, high daily use |
| Week 8-9 | Quote / Order Slip Generator (S5) | Professional tier upgrade |
| Week 10-11 | Daily Content Planner (G1) | 🔥 Daily habit creation |
| Week 11-12 | Seller Store Page (G2) | Requires Catalog complete |
| Week 12-13 | Auto Follow-Up Engine (G3) | Requires Catalog + Inquiries |
| Week 13-14 | Festival Packs Enhanced (G5) | Can be parallel to G3 |
| Week 14-15 | Sales Insight Dashboard (G4) | Final — needs all data |

**Critical Warning:** Do NOT build all 10 at once. Choose 2-3 per sprint. Finish them properly. A half-built CRM is worse than no CRM.

---

## Open Questions — v2.0

1. **Should Inquiry Tracker be a new tab or inside Catalog?** Recommend: new bottom nav tab (replaces or supplements "My Ads" tab in navigation) — to be decided after user interviews.
2. **Should Seller Store page use Dukaan AI domain or custom domain?** Start with `dukaan.ai/s/[slug]`. Custom domain in v3.1.
3. **Should Quick Replies allow AI-generation?** Not in v2.0. Seller edits templates manually. AI suggestion added in Phase 3.
4. **Should Order Slips include GST invoicing?** GST toggle off by default. Enable in v2.1 after validating demand from D2C founders (Persona 3).

---

*PRD Addendum v2.0 — Extends Dukaan AI PRD v1.0 (March 30, 2026)*  
*Author: Product Team | Status: Ready for Sprint Planning*
