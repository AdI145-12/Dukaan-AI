import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/account/presentation/screens/account_screen.dart';
import 'package:dukaan_ai/features/seller_store/application/seller_store_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

class _FakeDb {
  const _FakeDb({
    required this.userData,
    required this.generatedAdsCount,
  });

  final Map<String, dynamic> userData;
  final int generatedAdsCount;

  _FakeCollection collection(String name) {
    return _FakeCollection(
      name: name,
      userData: userData,
      generatedAdsCount: generatedAdsCount,
    );
  }
}

class _FakeCollection {
  const _FakeCollection({
    required this.name,
    required this.userData,
    required this.generatedAdsCount,
  });

  final String name;
  final Map<String, dynamic> userData;
  final int generatedAdsCount;

  _FakeDocRef doc(String userId) {
    return _FakeDocRef(userData: userData);
  }

  _FakeQuery where(String field, {required String isEqualTo}) {
    return _FakeQuery(count: generatedAdsCount);
  }
}

class _FakeDocRef {
  const _FakeDocRef({required this.userData});

  final Map<String, dynamic> userData;

  Future<_FakeDocSnapshot> get() async {
    return _FakeDocSnapshot(userData: userData);
  }
}

class _FakeDocSnapshot {
  const _FakeDocSnapshot({required this.userData});

  final Map<String, dynamic> userData;

  bool get exists => true;

  Map<String, dynamic> data() {
    return userData;
  }
}

class _FakeQuery {
  const _FakeQuery({required this.count});

  final int count;

  Future<_FakeQuerySnapshot> get() async {
    return _FakeQuerySnapshot(count: count);
  }
}

class _FakeQuerySnapshot {
  const _FakeQuerySnapshot({required this.count});

  final int count;

  List<Map<String, dynamic>> get docs => List<Map<String, dynamic>>.generate(
      count, (int _) => <String, dynamic>{});
}

void main() {
  setUp(FirebaseService.clearOverrides);
  tearDown(FirebaseService.clearOverrides);

  Widget buildSubject({required bool isStorePublished}) {
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );
    FirebaseService.setDbOverride(
      const _FakeDb(
        userData: <String, dynamic>{
          'shopName': 'Ramu Store',
          'category': 'Kirana',
          'city': 'Lucknow',
          'phone': '9876543210',
          'tier': 'free',
          'creditsRemaining': 3,
        },
        generatedAdsCount: 2,
      ),
    );

    return ProviderScope(
      overrides: [
        storeIsPublishedProvider.overrideWith((Ref ref) => isStorePublished),
      ],
      child: const MaterialApp(home: AccountScreen()),
    );
  }

  testWidgets('shows LIVE badge on My Store tile when published',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(isStorePublished: true));
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text(AppStrings.accountSellerStoreShortcut), findsOneWidget);
    expect(find.text(AppStrings.accountStoreLive), findsOneWidget);
  });

  testWidgets('shows DRAFT badge on My Store tile when unpublished',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(isStorePublished: false));
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text(AppStrings.accountSellerStoreShortcut), findsOneWidget);
    expect(find.text(AppStrings.accountStoreDraft), findsOneWidget);
  });
}
