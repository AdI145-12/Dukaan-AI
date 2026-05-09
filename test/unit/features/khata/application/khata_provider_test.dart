import 'package:dukaan_ai/core/providers/shared_providers.dart';
import 'package:dukaan_ai/features/khata/application/khata_provider.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/features/khata/domain/repositories/khata_repository.dart';
import 'package:dukaan_ai/features/khata/infrastructure/khata_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockKhataRepository extends Mock implements KhataRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
	late MockKhataRepository mockRepo;
	late MockSupabaseClient mockSupabaseClient;
	late MockGoTrueClient mockGoTrueClient;

	setUp(() {
		mockRepo = MockKhataRepository();
		mockSupabaseClient = MockSupabaseClient();
		mockGoTrueClient = MockGoTrueClient();

		when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
		when(() => mockGoTrueClient.currentUser).thenReturn(_testUser());
	});

	ProviderContainer createContainer() {
		final ProviderContainer container = ProviderContainer(
			overrides: [
				khataRepositoryProvider.overrideWithValue(mockRepo),
				supabaseClientProvider.overrideWith((Ref ref) => mockSupabaseClient),
			],
		);
		addTearDown(container.dispose);
		return container;
	}

	group('khataEntriesProvider', () {
		test('emits empty list when repository stream returns empty', () async {
			when(() => mockRepo.watchEntries(userId: any(named: 'userId')))
					.thenAnswer((_) => Stream<List<KhataEntry>>.value(const <KhataEntry>[]));

			final ProviderContainer container = createContainer();
			final ProviderSubscription<AsyncValue<List<KhataEntry>>> sub =
					container.listen(khataEntriesProvider, (_, __) {});
			addTearDown(sub.close);
			final List<KhataEntry> result = await container.read(khataEntriesProvider.future);

			expect(result, isEmpty);
			verify(() => mockRepo.watchEntries(userId: 'user-1')).called(1);
		});

		test('emits entries from repository stream', () async {
			final List<KhataEntry> testEntries = <KhataEntry>[
				KhataEntry(
					id: 'e1',
					userId: 'user-1',
					customerName: 'Amit',
					amount: 500,
					createdAt: DateTime(2026, 4, 1),
				),
			];

			when(() => mockRepo.watchEntries(userId: any(named: 'userId')))
					.thenAnswer((_) => Stream<List<KhataEntry>>.value(testEntries));

			final ProviderContainer container = createContainer();
			final ProviderSubscription<AsyncValue<List<KhataEntry>>> sub =
					container.listen(khataEntriesProvider, (_, __) {});
			addTearDown(sub.close);
			final List<KhataEntry> result = await container.read(khataEntriesProvider.future);

			expect(result, equals(testEntries));
			expect(result.first.customerName, 'Amit');
			verify(() => mockRepo.watchEntries(userId: 'user-1')).called(1);
		});
	});

	group('Khata notifier', () {
		test('addEntry calls repository.addEntry with correct params', () async {
			when(
				() => mockRepo.addEntry(
					userId: any(named: 'userId'),
					customerName: any(named: 'customerName'),
					customerPhone: any(named: 'customerPhone'),
					amount: any(named: 'amount'),
					type: any(named: 'type'),
					note: any(named: 'note'),
				),
			).thenAnswer((_) async {});

			final ProviderContainer container = createContainer();
			await container.read(khataProvider.notifier).addEntry(
						customerName: 'Rahul',
						amount: 1200,
					);

			verify(
				() => mockRepo.addEntry(
					userId: 'user-1',
					customerName: 'Rahul',
					customerPhone: null,
					amount: 1200,
					type: 'credit',
					note: null,
				),
			).called(1);
		});

		test('markPaid calls repository.markPaid', () async {
			when(() => mockRepo.markPaid(id: any(named: 'id'))).thenAnswer((_) async {});

			final ProviderContainer container = createContainer();
			await container.read(khataProvider.notifier).markPaid(id: 'e1');

			verify(() => mockRepo.markPaid(id: 'e1')).called(1);
		});

		test('deleteEntry calls repository.deleteEntry', () async {
			when(() => mockRepo.deleteEntry(id: any(named: 'id')))
					.thenAnswer((_) async {});

			final ProviderContainer container = createContainer();
			await container.read(khataProvider.notifier).deleteEntry(id: 'e1');

			verify(() => mockRepo.deleteEntry(id: 'e1')).called(1);
		});

		test('updateAmount calls repository.updateAmount with new value', () async {
			when(
				() => mockRepo.updateAmount(
					id: any(named: 'id'),
					newAmount: any(named: 'newAmount'),
				),
			).thenAnswer((_) async {});

			final ProviderContainer container = createContainer();
			await container.read(khataProvider.notifier).updateAmount(
						id: 'e1',
						newAmount: 900,
					);

			verify(() => mockRepo.updateAmount(id: 'e1', newAmount: 900)).called(1);
		});
	});
}

User _testUser() {
	return User(
		id: 'user-1',
		appMetadata: const <String, Object?>{},
		userMetadata: const <String, Object?>{},
		aud: 'authenticated',
		createdAt: DateTime(2026, 1, 1).toIso8601String(),
	);
}