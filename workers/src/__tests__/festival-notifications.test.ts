/// <reference path="../types/vitest-shim.d.ts" />

import { describe, expect, it } from 'vitest';

import type { FirestoreDocument, FirestoreValue } from '../lib/firebase-admin';
import { getFestivalsForDate, type Festival } from '../lib/festival-calendar';
import { filterUsersForFestival } from '../handlers/send-festival-notifications';

function makeStringField(value?: string): FirestoreValue | undefined {
	if (value == null) {
		return undefined;
	}

	return { stringValue: value };
}

function makeUserDoc(opts: {
	id: string;
	fcmToken?: string;
	category?: string;
	tier?: string;
}): FirestoreDocument {
	const fields: Record<string, FirestoreValue> = {};
	const fcmToken = makeStringField(opts.fcmToken);
	const category = makeStringField(opts.category);
	const tier = makeStringField(opts.tier);

	if (fcmToken) {
		fields.fcmToken = fcmToken;
	}
	if (category) {
		fields.category = category;
	}
	if (tier) {
		fields.tier = tier;
	}

	return {
		name: `projects/test/databases/(default)/documents/users/${opts.id}`,
		fields,
	};
}

describe('festival calendar helpers', () => {
	it('getFestivalsForDate returns empty for non-festival day', () => {
		const result = getFestivalsForDate('2026-06-15');

		expect(result.length).toBe(0);
	});

	it('getFestivalsForDate returns festival on festival day', () => {
		const result = getFestivalsForDate('2026-11-10');

		expect(result.length).toBe(1);
		expect(result[0]?.name).toBe('Diwali');
		expect(result[0]?.isReminder).toBe(false);
	});

	it('getFestivalsForDate returns 2-day reminder for major festival', () => {
		const result = getFestivalsForDate('2026-11-08');
		const reminderFound = result.some(
			(item) => item.name === 'Diwali' && item.isReminder,
		);

		expect(reminderFound).toBe(true);
	});
});

describe('filterUsersForFestival', () => {
	it('skips users without fcmToken', () => {
		const users: FirestoreDocument[] = [
			makeUserDoc({ id: 'with-token', fcmToken: 'abc123' }),
			makeUserDoc({ id: 'without-token' }),
		];

		const festival: Festival = {
			date: '2026-01-26',
			name: 'Republic Day',
			emoji: 'flag',
			category: 'national',
			targetCategories: [],
		};

		const filtered = filterUsersForFestival(users, festival);

		expect(filtered.length).toBe(1);
		expect(filtered[0]?.name).toContain('with-token');
	});

	it('respects category targeting', () => {
		const users: FirestoreDocument[] = [
			makeUserDoc({
				id: 'jewellery-user',
				fcmToken: 'token-a',
				category: 'Jewellery',
			}),
			makeUserDoc({
				id: 'electronics-user',
				fcmToken: 'token-b',
				category: 'Electronics',
			}),
			makeUserDoc({
				id: 'missing-category-user',
				fcmToken: 'token-c',
			}),
		];

		const festival: Festival = {
			date: '2026-11-08',
			name: 'Dhanteras',
			emoji: 'coins',
			category: 'hindu',
			targetCategories: ['Jewellery', 'Food'],
		};

		const filtered = filterUsersForFestival(users, festival);

		expect(filtered.length).toBe(1);
		expect(filtered[0]?.name).toContain('jewellery-user');
	});
});