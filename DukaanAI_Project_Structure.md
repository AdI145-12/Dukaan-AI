# Dukaan AI — Production-Grade Project Directory Structure

## Flutter + Supabase + Cloudflare Workers | Full Stack

#### Version 1.0 | April 2026 | Total: 279 files across 91 directories

## Architecture Philosophy

#### This structure follows Feature-First Clean Architecture: Each feature is fully self-contained (domain → infrastructure → application → presentation) Features communicate only via Riverpod providers, never by importing each other directly The core/ layer is imported by features; features never import each other The shared/ layer holds reusable widgets and cross-cutting providers only workers/ (Cloudflare) and supabase/ are standalone projects — they share no code with Flutter

Rule: If feature A needs data from feature B → use a shared Riverpod provid

Rule: If a widget is used in 2+ features → move it to shared/widgets/

Rule: If a utility is used in 2+ features → move it to core/utils/

## Complete Directory Tree


dukaan-ai/

│

├── 📄 pubspec.yaml            # All Flutter dependencies + asset declaratio


├── 📄 pubspec.lock            # Locked dependency versions (commit this

├── 📄 analysis_options.yaml        # Dart linting rules (very strict for prod)

├── 📄 build.yaml             # Riverpod/Freezed code gen config

├── 📄 Makefile              # Shortcuts: make gen, make test, make build

├── 📄 README.md              # Project setup guide

├── 📄 .env.example            # Template for env vars (never commit .env

├── 📄 .gitignore             # Excludes: .env, *.g.dart (generated), build/

│

├── 📁 android/

│ ├── 📁 app/

│ │ ├── 📄 build.gradle        # Release signing, min SDK 21, ProGuard ru

│ │ ├── 📄 google-services.json    # Firebase config (from Firebase Conso

│ │ └── 📄 proguard-rules.pro     # Keep rules for Razorpay, Firebase, Su

│ └── 📄 key.properties.example     # Keystore config template (never comm

│

├── 📁 assets/

│ ├── 📁 icons/

│ │ ├── 🖼️ app_icon.png        # 1024x1024 app icon (source)

│ │ └── 🖼️ app_icon_foreground.png  # Adaptive icon foreground layer

│ ├── 📁 splash/

│ │ └── 🖼️ splash_logo.png      # White logo for saffron splash screen

│ ├── 📁 lottie/

│ │ ├── 🎬 welcome_animation.json   # Shop/dukaan animation for onbo

│ │ ├── 🎬 ad_generating.json     # Sparkles animation during AI generat

│ │ └── 🎬 payment_success.json    # Confetti for payment success screen

│ └── 📁 images/

│ ├── 🖼️ empty_ads.png       # Empty state illustration for My Ads

│ └── 🖼️ empty_khata.png      # Empty state illustration for Khata

│

├── 📁 lib/

│ ├── 📄 main.dart            # App entry: init Supabase, Firebase, run app

│ ├── 📄 app.dart            # MaterialApp.router with GoRouter + theme

│ │

│ ├── 📁 core/              # App-wide: no business logic, no UI

│ │ │

│ │ ├── 📁 config/

│ │ │ ├── 📄 app_config.dart     # App name, version, flavor (dev/prod)

│ │ │ └── 📄 env.dart        # Reads env vars: Supabase URL/key, Worke


│ │ │

│ │ ├── 📁 router/

│ │ │ ├── 📄 app_router.dart     # GoRouter definition: all routes + redire

│ │ │ ├── 📄 app_routes.dart     # Route name constants: AppRoutes.stud

│ │ │ └── 📄 router_guards.dart   # Auth guard: redirects unauthenticate

│ │ │

│ │ ├── 📁 theme/

│ │ │ ├── 📄 app_theme.dart     # ThemeData (light + dark) using tokens

│ │ │ ├── 📄 app_colors.dart     # AppColors.primary = Color(0xFFFF6F0

│ │ │ ├── 📄 app_typography.dart   # TextTheme with Noto Sans, size scal

│ │ │ ├── 📄 app_spacing.dart    # AppSpacing.xs=4, sm=8, md=16, lg=24,

│ │ │ ├── 📄 app_radius.dart     # AppRadius.card=12, button=8, chip=20

│ │ │ └── 📄 app_shadows.dart    # AppShadows.card, AppShadows.mod

│ │ │

│ │ ├── 📁 constants/

│ │ │ ├── 📄 app_strings.dart    # ALL user-facing strings (Hinglish + En

│ │ │ ├── 📄 app_assets.dart     # Asset path constants: AppAssets.lottieW

│ │ │ ├── 📄 api_endpoints.dart   # Worker endpoint paths: ApiEndpoint

│ │ │ ├── 📄 supabase_tables.dart  # SupabaseTables.profiles = 'profiles' e

│ │ │ └── 📄 supabase_columns.dart  # SupabaseColumns.userId = 'user_

│ │ │

│ │ ├── 📁 supabase/

│ │ │ ├── 📄 supabase_client.dart  # Singleton: SupabaseClient.instance

│ │ │ └── 📄 supabase_auth_service.dart # Phone OTP, session manageme

│ │ │

│ │ ├── 📁 errors/

│ │ │ ├── 📄 app_exception.dart   # Sealed class: AppException (supabase

│ │ │ ├── 📄 error_handler.dart   # Maps exceptions to user-friendly Hin

│ │ │ └── 📄 failure.dart      # Either<Failure, T> pattern for repository

│ │ │

│ │ ├── 📁 utils/

│ │ │ ├── 📄 logger.dart       # Wrapper over logger package (no print()

│ │ │ ├── 📄 image_pipeline.dart   # Compress + resize + base64 (runs in

│ │ │ ├── 📄 credit_guard.dart    # Check credits → deduct → or show no

│ │ │ ├── 📄 festival_calendar.dart # Indian festivals 2026-2027 → getToda

│ │ │ ├── 📄 upi_utils.dart     # Build UPI deep link string for QR code

│ │ │ ├── 📄 share_utils.dart    # shareToWhatsApp(), shareImageFile(),

│ │ │ └── 📄 validators.dart     # validatePhone(), validateUpiId(), valida


│ │ │

│ │ ├── 📁 extensions/

│ │ │ ├── 📄 string_extensions.dart # .toHinglishDate(), .truncate(n), .isVa

│ │ │ ├── 📄 datetime_extensions.dart# .toRelativeString() → "2 ghante pe

│ │ │ ├── 📄 context_extensions.dart # context.showSnackBar(), context.s

│ │ │ └── 📄 num_extensions.dart   # .toRupees() → "₹1,299", .toCompact(

│ │ │

│ │ └── 📁 network/

│ │ ├── 📄 network_info.dart    # Connectivity check using connectivity

│ │ └── 📄 cloudflare_client.dart # HTTP client for Worker API calls + err

│ │

│ ├── 📁 features/

│ │ │

│ │ ├── 📁 auth/            # FEATURE: Onboarding + Phone OTP login

│ │ │ ├── 📁 domain/

│ │ │ │ ├── 📁 models/

│ │ │ │ │ ├── 📄 user_profile.dart     # @freezed: id, shopName, tier, c

│ │ │ │ │ ├── 📄 user_profile.freezed.dart # Generated — do not edit m

│ │ │ │ │ └── 📄 user_tier.dart       # enum UserTier { free, dukaan, v

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 auth_repository.dart    # Abstract: signInWithPhone, v

│ │ │ │

│ │ │ ├── 📁 infrastructure/

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 auth_repository_impl.dart  # Supabase OTP impl, profil

│ │ │ │

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 auth_provider.dart       # @riverpod AsyncNotifier<Use

│ │ │ │ ├── 📄 auth_provider.g.dart      # Generated

│ │ │ │ ├── 📄 auth_state.dart         # @freezed AuthState: initial/otpS

│ │ │ │ ├── 📄 auth_state.freezed.dart     # Generated

│ │ │ │ ├── 📄 onboarding_provider.dart    # Manages 3-step onboardin

│ │ │ │ └── 📄 onboarding_provider.g.dart   # Generated

│ │ │ │

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ ├── 📄 welcome_screen.dart     # Screen 1: Lottie + CTA

│ │ │ │ ├── 📄 business_setup_screen.dart  # Screen 2: shop name + ca


│ │ │ │ └── 📄 phone_auth_screen.dart    # Screen 3: +91 input + 6-bo

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 language_toggle.dart     # हिदी / Hinglish / English pill to

│ │ │ ├── 📄 otp_input_field.dart     # 6-box PIN input, auto-advance

│ │ │ └── 📄 onboarding_progress_dots.dart# 3 dots, orange = curren

│ │ │

│ │ ├── 📁 studio/           # FEATURE: Core AI ad generation flow (PRIM

│ │ │ ├── 📁 domain/

│ │ │ │ ├── 📁 models/

│ │ │ │ │ ├── 📄 generated_ad.dart       # @freezed: id, imageUrl, cap

│ │ │ │ │ ├── 📄 generated_ad.freezed.dart   # Generated

│ │ │ │ │ ├── 📄 background_style.dart     # enum + metadata: palace

│ │ │ │ │ ├── 📄 ad_creation_request.dart    # @freezed: productImage

│ │ │ │ │ └── 📄 ad_creation_request.freezed.dart

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 studio_repository.dart     # Abstract: removeBackgrou

│ │ │ │

│ │ │ ├── 📁 infrastructure/

│ │ │ │ ├── 📁 repositories/

│ │ │ │ │ └── 📄 studio_repository_impl.dart   # Coordinates datasourc

│ │ │ │ └── 📁 datasources/

│ │ │ │ ├── 📄 bg_removal_datasource.dart   # Calls Worker /api/rem

│ │ │ │ ├── 📄 bg_generation_datasource.dart  # Calls Worker /api/gen

│ │ │ │ └── 📄 caption_datasource.dart     # Calls Worker /api/genera

│ │ │ │

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 studio_provider.dart        # Recent ads, home screen st

│ │ │ │ ├── 📄 studio_provider.g.dart

│ │ │ │ ├── 📄 studio_state.dart          # @freezed StudioState

│ │ │ │ ├── 📄 studio_state.freezed.dart

│ │ │ │ ├── 📄 ad_creation_provider.dart      # Full ad creation flow sta

│ │ │ │ ├── 📄 ad_creation_provider.g.dart     # Steps: idle → capturing →

│ │ │ │ ├── 📄 ad_creation_state.dart       # @freezed AdCreationState

│ │ │ │ ├── 📄 ad_creation_state.freezed.dart

│ │ │ │ ├── 📄 caption_provider.dart        # Caption generation + lang

│ │ │ │ └── 📄 caption_provider.g.dart

│ │ │ │

│ │ │ └── 📁 presentation/


│ │ │ ├── 📁 screens/

│ │ │ │ ├── 📄 studio_home_screen.dart     # Main tab: greeting, qui

│ │ │ │ ├── 📄 background_select_screen.dart  # Style grid + custom p

│ │ │ │ └── 📄 ad_result_screen.dart      # Final ad: preview + captio

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 quick_action_card.dart      # 📦 Product / 🎉 Festival / etc.

│ │ │ ├── 📄 ad_card.dart           # Thumbnail + date + share icon

│ │ │ ├── 📄 shimmer_ad_card.dart       # Skeleton loading placeho

│ │ │ ├── 📄 image_capture_sheet.dart     # Camera vs Gallery botto

│ │ │ ├── 📄 background_style_grid.dart    # 2-row horizontal scroll

│ │ │ ├── 📄 caption_editor.dart       # Editable caption + hashtag p

│ │ │ ├── 📄 share_action_bar.dart      # Save / Share / WhatsApp / R

│ │ │ ├── 📄 festival_banner.dart       # "Aaj Diwali hai!" orange car

│ │ │ ├── 📄 generating_overlay.dart     # Full-screen overlay durin

│ │ │ └── 📄 credit_indicator.dart      # " ⚡ 5 ads bache hain" pill bad

│ │ │

│ │ ├── 📁 my_ads/           # FEATURE: Saved ads gallery

│ │ │ ├── 📁 domain/

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 ads_repository.dart       # Abstract: getAdsPaginated,

│ │ │ ├── 📁 infrastructure/

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 ads_repository_impl.dart     # Supabase .range() pagin

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 my_ads_provider.dart         # Paginated ads list + filter

│ │ │ │ ├── 📄 my_ads_provider.g.dart

│ │ │ │ ├── 📄 my_ads_state.dart           # @freezed: ads, filter, hasM

│ │ │ │ └── 📄 my_ads_state.freezed.dart

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ └── 📄 my_ads_screen.dart        # 2-col grid + filter bar + sta

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 ads_filter_bar.dart        # All / This Week / Festival chi

│ │ │ ├── 📄 ads_grid.dart           # 2-col grid with infinite scroll

│ │ │ ├── 📄 ad_action_menu.dart        # Long-press: Share/Downl

│ │ │ └── 📄 ads_stats_bar.dart        # Total: X | Shared: Y | Downl

│ │ │

│ │ ├── 📁 khata/           # FEATURE: Digital credit ledger


│ │ │ ├── 📁 domain/

│ │ │ │ ├── 📁 models/

│ │ │ │ │ ├── 📄 khata_entry.dart         # @freezed: id, name, phone

│ │ │ │ │ └── 📄 khata_entry.freezed.dart

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 khata_repository.dart       # Abstract: getEntries, add,

│ │ │ ├── 📁 infrastructure/

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 khata_repository_impl.dart    # Supabase realtime stre

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 khata_provider.dart          # StreamProvider (realtime

│ │ │ │ ├── 📄 khata_provider.g.dart

│ │ │ │ ├── 📄 khata_state.dart           # @freezed: entries, totalPend

│ │ │ │ └── 📄 khata_state.freezed.dart

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ └── 📄 khata_screen.dart         # Summary card + list + FAB

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 khata_summary_card.dart      # "₹X baaki hai" orange

│ │ │ ├── 📄 khata_entry_card.dart       # Avatar + name + amount (

│ │ │ ├── 📄 add_entry_sheet.dart       # Bottom sheet: name + pho

│ │ │ └── 📄 reminder_message_preview.dart   # WhatsApp reminde

│ │ │

│ │ ├── 📁 catalogue/         # FEATURE: Shareable product catalogue

│ │ │ ├── 📁 domain/

│ │ │ │ ├── 📁 models/

│ │ │ │ │ ├── 📄 catalogue.dart          # @freezed: id, name, produc

│ │ │ │ │ ├── 📄 catalogue.freezed.dart

│ │ │ │ │ ├── 📄 catalogue_product.dart      # @freezed: name, price,

│ │ │ │ │ └── 📄 catalogue_product.freezed.dart

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 catalogue_repository.dart     # Abstract: getCatalogues

│ │ │ ├── 📁 infrastructure/

│ │ │ │ └── 📁 repositories/

│ │ │ │ └── 📄 catalogue_repository_impl.dart  # Supabase storage + p

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 catalogue_provider.dart

│ │ │ │ ├── 📄 catalogue_provider.g.dart


│ │ │ │ ├── 📄 catalogue_state.dart

│ │ │ │ └── 📄 catalogue_state.freezed.dart

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ ├── 📄 catalogue_list_screen.dart    # List of catalogues + FAB

│ │ │ │ ├── 📄 create_catalogue_screen.dart   # 3-step: setup → produ

│ │ │ │ └── 📄 catalogue_preview_screen.dart   # Preview + share link

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 catalogue_card.dart        # Name + count + date + shar

│ │ │ ├── 📄 product_entry_card.dart      # Drag-reorder card with i

│ │ │ └── 📄 add_product_sheet.dart      # Camera/gallery + name +

│ │ │

│ │ ├── 📁 upi_poster/         # FEATURE: UPI payment QR poster generat

│ │ │ ├── 📁 domain/

│ │ │ │ └── 📁 models/

│ │ │ │ ├── 📄 upi_poster_config.dart      # @freezed: shopName, up

│ │ │ │ └── 📄 upi_poster_config.freezed.dart

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 upi_poster_provider.dart       # Local state only — no S

│ │ │ │ └── 📄 upi_poster_provider.g.dart

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ └── 📄 upi_poster_screen.dart      # 3-step: info → style → pr

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 poster_style_selector.dart    # 4 template cards (2x2)

│ │ │ ├── 📄 poster_preview.dart        # Canvas-rendered poster pr

│ │ │ └── 📄 qr_display_widget.dart      # QR code widget using qr_

│ │ │

│ │ ├── 📁 pricing/          # FEATURE: Plans, ad packs, Razorpay payme

│ │ │ ├── 📁 domain/

│ │ │ │ ├── 📁 models/

│ │ │ │ │ ├── 📄 plan.dart             # @freezed: id, name, price, fea

│ │ │ │ │ ├── 📄 plan.freezed.dart

│ │ │ │ │ ├── 📄 ad_pack.dart           # @freezed: id, label, price, cr

│ │ │ │ │ ├── 📄 ad_pack.freezed.dart

│ │ │ │ │ ├── 📄 payment_result.dart        # @freezed: success/failur

│ │ │ │ │ └── 📄 payment_result.freezed.dart

│ │ │ │ └── 📁 repositories/


│ │ │ │ └── 📄 payment_repository.dart      # Abstract: createOrder, v

│ │ │ ├── 📁 infrastructure/

│ │ │ │ ├── 📁 repositories/

│ │ │ │ │ └── 📄 payment_repository_impl.dart   # Coordinates dataso

│ │ │ │ └── 📁 datasources/

│ │ │ │ └── 📄 razorpay_datasource.dart     # Razorpay Flutter SDK i

│ │ │ ├── 📁 application/

│ │ │ │ ├── 📄 pricing_provider.dart         # Plan list + active plan fro

│ │ │ │ ├── 📄 pricing_provider.g.dart

│ │ │ │ ├── 📄 payment_provider.dart         # Full payment flow state

│ │ │ │ ├── 📄 payment_provider.g.dart

│ │ │ │ ├── 📄 payment_state.dart          # @freezed: idle/processing

│ │ │ │ └── 📄 payment_state.freezed.dart

│ │ │ └── 📁 presentation/

│ │ │ ├── 📁 screens/

│ │ │ │ ├── 📄 pricing_screen.dart        # Monthly plans ↔ Ad pack

│ │ │ │ └── 📄 payment_success_screen.dart    # Confetti + plan name

│ │ │ └── 📁 widgets/

│ │ │ ├── 📄 plan_card.dart          # Plan: name + price + features

│ │ │ ├── 📄 ad_pack_card.dart         # Pack: label + price + credits

│ │ │ ├── 📄 plan_toggle.dart         # [Monthly Plans] [Ad Packs] p

│ │ │ └── 📄 no_credits_sheet.dart       # "Credits khatam!" → pricin

│ │ │

│ │ └── 📁 account/          # FEATURE: User profile + settings

│ │ ├── 📁 domain/

│ │ │ └── 📁 repositories/

│ │ │ └── 📄 profile_repository.dart      # Abstract: getProfile, updat

│ │ ├── 📁 infrastructure/

│ │ │ └── 📁 repositories/

│ │ │ └── 📄 profile_repository_impl.dart   # Supabase profiles table

│ │ ├── 📁 application/

│ │ │ ├── 📄 profile_provider.dart         # Current user profile (share

│ │ │ ├── 📄 profile_provider.g.dart

│ │ │ ├── 📄 notification_settings_provider.dart  # FCM token + permiss

│ │ │ └── 📄 notification_settings_provider.g.dart

│ │ └── 📁 presentation/

│ │ ├── 📁 screens/

│ │ │ ├── 📄 account_screen.dart        # Profile card + menu sectio


│ │ │ ├── 📄 edit_profile_screen.dart     # Edit shop name, category,

│ │ │ └── 📄 notification_settings_screen.dart # Festival notifications

│ │ └── 📁 widgets/

│ │ ├── 📄 profile_header_card.dart     # Orange gradient: avatar +

│ │ ├── 📄 account_menu_item.dart      # Icon + label + arrow row

│ │ └── 📄 account_menu_section.dart     # Titled group of menu it

│ │

│ └── 📁 shared/             # Cross-feature reusables (no business logic)

│ ├── 📁 widgets/

│ │ ├── 📄 app_button.dart     # AppButton: primary / secondary / ghos

│ │ ├── 📄 app_text_field.dart   # AppTextField: orange focus, Hinglish l

│ │ ├── 📄 app_bottom_sheet.dart  # Standard bottom sheet: drag handle

│ │ ├── 📄 app_snackbar.dart    # showAppSnackBar(context, message,

│ │ ├── 📄 app_loading_overlay.dart # Full-screen overlay with Lottie + s

│ │ ├── 📄 app_error_view.dart   # Error screen: icon + message + retry

│ │ ├── 📄 app_empty_state.dart   # Empty state: illustration + title + CTA

│ │ ├── 📄 avatar_circle.dart    # Colored circle with first letter (hash-ba

│ │ ├── 📄 shimmer_box.dart     # Animated shimmer rectangle for loa

│ │ ├── 📄 cached_ad_image.dart   # CachedNetworkImage + shimmer +

│ │ ├── 📄 credit_badge.dart    # " ⚡ N ads bache" orange pill

│ │ ├── 📄 hindi_caption_text.dart # Text widget configured for Devanag

│ │ ├── 📄 bottom_nav_bar.dart   # Main bottom nav: Studio / My Ads / A

│ │ └── 📄 section_header.dart   # "Title" + "See All → " row

│ │

│ └── 📁 providers/

│ ├── 📄 fcm_provider.dart    # Firebase FCM: token retrieval + messag

│ ├── 📄 fcm_provider.g.dart

│ ├── 📄 connectivity_provider.dart # Real-time network status (offline b

│ └── 📄 connectivity_provider.g.dart

│

├── 📁 workers/              # CLOUDFLARE WORKERS (standalone TypeS

│ ├── 📄 package.json          # Dependencies: wrangler, typescript, vitest

│ ├── 📄 tsconfig.json          # TypeScript config for Workers runtime

│ ├── 📄 wrangler.toml          # Routes, KV bindings, env var declaration

│ ├── 📄 .dev.vars.example        # Local dev env vars template

│ │

│ └── 📁 src/

│ ├── 📄 index.ts          # Main router: match URL path → call handler


│ │

│ ├── 📁 types/

│ │ ├── 📄 env.ts         # Env interface: all env var types declared

│ │ ├── 📄 requests.ts       # Input interfaces per endpoint

│ │ ├── 📄 responses.ts      # Output interfaces (success/error shapes)

│ │ └── 📄 supabase.ts       # Supabase row types (mirrors DB schema)

│ │

│ ├── 📁 middleware/

│ │ ├── 📄 cors.ts         # corsHeaders constant + OPTIONS handler

│ │ ├── 📄 auth.ts         # verifyUser(userId, env) → boolean

│ │ └── 📄 rate_limit.ts      # checkRateLimit(key, limit, env) → boolean

│ │

│ ├── 📁 handlers/          # One file = one endpoint

│ │ ├── 📄 remove_bg.ts      # POST /api/remove-bg → AI Engine API

│ │ ├── 📄 generate_background.ts # POST /api/generate-background → R

│ │ ├── 📄 generate_caption.ts   # POST /api/generate-caption → OpenAI

│ │ ├── 📄 create_order.ts     # POST /api/create-order → Razorpay order

│ │ ├── 📄 verify_payment.ts    # POST /api/verify-payment → HMAC ve

│ │ └── 📄 send_festival_notifications.ts # CRON: daily 6AM IST → FCM b

│ │

│ ├── 📁 services/          # Reusable external API wrappers

│ │ ├── 📄 ai_engine_service.ts  # Background removal API wrapper

│ │ ├── 📄 replicate_service.ts  # Flux image generation wrapper

│ │ ├── 📄 openai_service.ts    # GPT-4o-mini caption generation

│ │ ├── 📄 razorpay_service.ts   # Order creation + HMAC signature veri

│ │ ├── 📄 supabase_service.ts   # Fetch/update Supabase rows via REST

│ │ └── 📄 fcm_service.ts     # Firebase batch push notification sender

│ │

│ ├── 📁 utils/

│ │ ├── 📄 response.ts       # jsonSuccess(), jsonError() helpers

│ │ ├── 📄 validators.ts      # validateBody(), isValidUUID(), isValidAmo

│ │ ├── 📄 crypto.ts        # verifyHmacSha256() for Razorpay signature

│ │ └── 📄 logger.ts       # Structured logging for Cloudflare Analytics

│ │

│ └── 📁 test/ (workers/test/)

│ ├── 📄 handlers/remove_bg.test.ts

│ ├── 📄 handlers/generate_caption.test.ts

│ ├── 📄 handlers/create_order.test.ts


│ ├── 📄 handlers/verify_payment.test.ts

│ └── 📄 services/razorpay_service.test.ts

│

├── 📁 supabase/              # SUPABASE PROJECT (standalone)

│ ├── 📄 config.toml           # Supabase local dev config

│ ├── 📄 seed.sql            # Dev seed: test users, sample ads, sample kha

│ │

│ ├── 📁 migrations/           # Run in order — never edit existing migrat

│ │ ├── 📄 20260401000001_create_profiles.sql     # profiles table + RLS + t

│ │ ├── 📄 20260401000002_create_generated_ads.sql   # generated_ads + R

│ │ ├── 📄 20260401000003_create_khata_entries.sql   # khata_entries + RL

│ │ ├── 📄 20260401000004_create_transactions.sql   # transactions + RLS

│ │ ├── 📄 20260401000005_create_usage_events.sql   # usage_events + RL

│ │ ├── 📄 20260401000006_create_catalogues.sql    # catalogues + catalogu

│ │ ├── 📄 20260401000007_create_functions.sql     # decrement_credits(),

│ │ └── 📄 20260401000008_create_indexes.sql      # All performance inde

│ │

│ └── 📁 functions/           # Supabase Edge Functions (Deno runtime)

│ ├── 📁 create-razorpay-order/

│ │ └── 📄 index.ts        # Creates Razorpay order + inserts pending tr

│ ├── 📁 verify-payment/

│ │ └── 📄 index.ts        # Verifies HMAC + updates tier + credits

│ ├── 📁 send-festival-notifications/

│ │ └── 📄 index.ts        # Daily cron: check festival + batch FCM push

│ └── 📁 _shared/

│ ├── 📄 cors.ts         # Shared CORS headers for all Edge Functions

│ └── 📄 supabase_admin.ts    # Supabase admin client (service key)

│

└── 📁 test/               # FLUTTER TESTS

├── 📁 helpers/

│ ├── 📄 test_data.dart       # Factory: testUserProfile(), testKhataEntry()

│ ├── 📄 mock_providers.dart     # ProviderContainer overrides for all r

│ └── 📄 fake_notifiers.dart     # FakeStudioNotifier, FakePaymentNotifie

│

├── 📁 unit/

│ ├── 📁 core/utils/

│ │ ├── 📄 image_pipeline_test.dart     # Compression ratios, base64 ou

│ │ ├── 📄 credit_guard_test.dart       # 0 credits, unlimited tier, decrem


│ │ ├── 📄 festival_calendar_test.dart    # Date matching, 2-day advance

│ │ └── 📄 validators_test.dart        # Phone, UPI ID, shop name valida

│ │

│ └── 📁 features/

│ ├── 📄 auth/auth_provider_test.dart    # OTP flow state transitions

│ ├── 📄 auth/auth_repository_test.dart   # Supabase OTP mock + profil

│ ├── 📄 studio/studio_provider_test.dart  # Recent ads loading, empty s

│ ├── 📄 studio/ad_creation_provider_test.dart # Full flow: capture → rem

│ ├── 📄 studio/studio_repository_test.dart # Repository coordination te

│ ├── 📄 studio/bg_removal_datasource_test.dart # Worker API call moc

│ ├── 📄 khata/khata_provider_test.dart   # CRUD + total calculation

│ ├── 📄 khata/khata_repository_test.dart  # Supabase realtime stream m

│ ├── 📄 pricing/payment_provider_test.dart # idle → processing → succes

│ ├── 📄 pricing/payment_repository_test.dart

│ └── 📄 pricing/razorpay_datasource_test.dart # SDK mock, error codes

│

├── 📁 widget/

│ └── 📁 features/

│ ├── 📄 auth/welcome_screen_test.dart    # Renders CTA, tap navigate

│ ├── 📄 studio/studio_home_screen_test.dart # Loading/data/empty stat

│ ├── 📄 studio/ad_result_screen_test.dart  # Share bar, watermark togg

│ ├── 📄 khata/khata_screen_test.dart    # Total card, list, FAB

│ └── 📄 pricing/pricing_screen_test.dart  # Toggle, plan cards, CTA stat

│

└── 📁 integration/

├── 📄 auth_flow_test.dart      # Welcome → Setup → OTP → Main app

├── 📄 ad_generation_flow_test.dart # Camera → BG Remove → Style → R

└── 📄 payment_flow_test.dart    # Pricing → Razorpay → Success → Cre

## Key Architectural Decisions Explained

### Why Feature-First over Layer-First?

#### jump between 5 folders.


#### Feature-first keeps everything for one feature together. New developer onboards to a feature, not the entire codebase.

### Why .freezed.dart and .g.dart files are in the tree

#### These are generated files from build_runner. They are committed to git because: CI/CD doesn't need to run code generation on every build Reviewers can see what was generated vs what was written .gitignore can exclude them if the team prefers CI generation Add this to Makefile for easy regeneration:

gen:


flutter pub run build_runner build --delete-conflicting-outputs


watch:


flutter pub run build_runner watch --delete-conflicting-outputs

### Why Workers and Supabase are Separate Project Roots

#### They run on completely different runtimes (V8 isolates, Deno) and have their own package.json / config. Keeping them in the same repo (monorepo) gives you one git history but clean separation. Never import Flutter code from Workers or vice versa.

### The Data Flow for Ad Generation


User taps "Generate Ad"

→ CreditGuard.canPerformAction() [core/utils]

→ If OK: AdCreationProvider.startCapture() [studio/application]

→ ImagePipeline.prepareForUpload() [core/utils, runs in Isolate]

→ CloudflareClient.post('/api/remove-bg') [core/network]

→ [Cloudflare Worker: remove_bg.ts]

→ AI Engine API

→ Returns transparent image URL

→ Navigate to BackgroundSelectScreen

→ User selects style


→ CloudflareClient.post('/api/generate-background')

→ [Cloudflare Worker: generate_background.ts]

→ Replicate Flux API

→ Returns final image URL

→ StudioRepository.saveAd() [studio/infrastructure]

→ Supabase: INSERT into generated_ads

→ Navigate to AdResultScreen

→ CaptionProvider.generateCaption()

→ CloudflareClient.post('/api/generate-caption')

→ User shares → shareUtils.shareToWhatsApp()

## File Count by Layer

|Layer|File<br>s|Purpose|
|---|---|---|
|lib/core/|38|App-wide setup, no business logic|
|lib/features/ (8<br>features)|148|All business logic, feature-isolated|
|lib/shared/|18|Cross-feature reusable UI +<br>providers|
|workers/src/|23|Serverless AI API proxy<br>(TypeScript)|
|supabase/|14|Migrations + Edge Functions<br>(SQL/Deno)|
|test/|28|Unit + widget + integration tests|
|Root confg|10|Build, Android, assets|
|Total|279|Production-ready Flutter<br>monorepo|


#### Generated: April 01, 2026 | Dukaan AI Architecture v1.0


