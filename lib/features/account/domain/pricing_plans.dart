enum PlanTier {
  free,
  dukaan,
  vyapaar,
  utsav,
}

/// Immutable monthly subscription plan definition.
class Plan {
  const Plan({
    required this.tier,
    required this.name,
    required this.price,
    required this.amountPaise,
    required this.adsPerMonth,
    required this.features,
    required this.isMostPopular,
    required this.isHighlighted,
  });

  final PlanTier tier;
  final String name;
  final String price;
  final int amountPaise;
  final int adsPerMonth;
  final List<String> features;
  final bool isMostPopular;
  final bool isHighlighted;
}

/// Immutable one-time ad pack definition.
class AdPack {
  const AdPack({
    required this.id,
    required this.name,
    required this.price,
    required this.amountPaise,
    required this.creditsGranted,
    required this.badge,
    required this.isRecommended,
  });

  final String id;
  final String name;
  final String price;
  final int amountPaise;
  final int creditsGranted;
  final String badge;
  final bool isRecommended;
}

const List<Plan> kPlans = <Plan>[
  Plan(
    tier: PlanTier.free,
    name: 'Free',
    price: '₹0',
    amountPaise: 0,
    adsPerMonth: 5,
    features: <String>[
      '5 ads/month',
      'Basic backgrounds only',
      'Watermark on ads',
      'Caption generator',
    ],
    isMostPopular: false,
    isHighlighted: false,
  ),
  Plan(
    tier: PlanTier.dukaan,
    name: 'Dukaan',
    price: '₹99/mo',
    amountPaise: 9900,
    adsPerMonth: 50,
    features: <String>[
      '50 ads/month',
      'All backgrounds',
      'No watermark',
      'Caption generator',
      'Khata ledger',
    ],
    isMostPopular: false,
    isHighlighted: false,
  ),
  Plan(
    tier: PlanTier.vyapaar,
    name: 'Vyapaar',
    price: '₹249/mo',
    amountPaise: 24900,
    adsPerMonth: 150,
    features: <String>[
      '150 ads/month',
      'All Dukaan features',
      'WhatsApp Broadcast',
      'Festival theme presets',
      'Priority processing',
    ],
    isMostPopular: true,
    isHighlighted: true,
  ),
  Plan(
    tier: PlanTier.utsav,
    name: 'Utsav',
    price: '₹499/mo',
    amountPaise: 49900,
    adsPerMonth: 999999,
    features: <String>[
      'Unlimited ads',
      'All Vyapaar features',
      'API access (Phase 2)',
      'Priority support',
      'Analytics dashboard',
    ],
    isMostPopular: false,
    isHighlighted: false,
  ),
];

const List<AdPack> kAdPacks = <AdPack>[
  AdPack(
    id: 'starter_pack',
    name: 'Starter Pack',
    price: '₹29',
    amountPaise: 2900,
    creditsGranted: 10,
    badge: '',
    isRecommended: false,
  ),
  AdPack(
    id: 'value_pack',
    name: 'Value Pack',
    price: '₹99',
    amountPaise: 9900,
    creditsGranted: 50,
    badge: 'Best Value',
    isRecommended: true,
  ),
  AdPack(
    id: 'festival_pack',
    name: 'Festival Pack',
    price: '₹199',
    amountPaise: 19900,
    creditsGranted: -1,
    badge: '7 din unlimited',
    isRecommended: false,
  ),
];

/// Maps Firestore tier strings to local enum values.
PlanTier planTierFromId(String tier) {
  return switch (tier) {
    'dukaan_monthly' => PlanTier.dukaan,
    'dukaan' => PlanTier.dukaan,
    'vyapaar_monthly' => PlanTier.vyapaar,
    'vyapaar' => PlanTier.vyapaar,
    'utsav_monthly' => PlanTier.utsav,
    'utsav' => PlanTier.utsav,
    _ => PlanTier.free,
  };
}
