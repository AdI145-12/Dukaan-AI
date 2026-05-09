export interface Festival {
	date: string;
	name: string;
	emoji: string;
	category: 'hindu' | 'muslim' | 'christian' | 'sikh' | 'national';
	targetCategories: string[];
}

export type FestivalWithReminder = Festival & { isReminder: boolean };

export const FESTIVALS_2026: Festival[] = [
	{
		date: '2026-01-14',
		name: 'Makar Sankranti',
		emoji: '\u{1FA81}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-01-26',
		name: 'Republic Day',
		emoji: '\u{1F1EE}\u{1F1F3}',
		category: 'national',
		targetCategories: [],
	},
	{
		date: '2026-03-20',
		name: 'Holi',
		emoji: '\u{1F3A8}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-03-31',
		name: 'Eid ul-Fitr',
		emoji: '\u{1F319}',
		category: 'muslim',
		targetCategories: ['Food', 'Apparel', 'Jewellery'],
	},
	{
		date: '2026-04-02',
		name: 'Ram Navami',
		emoji: '\u{1F64F}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-08-15',
		name: 'Independence Day',
		emoji: '\u{1F1EE}\u{1F1F3}',
		category: 'national',
		targetCategories: [],
	},
	{
		date: '2026-08-20',
		name: 'Raksha Bandhan',
		emoji: '\u{1F380}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-08-29',
		name: 'Janmashtami',
		emoji: '\u{1F99A}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-09-15',
		name: 'Onam',
		emoji: '\u{1F338}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-10-02',
		name: 'Gandhi Jayanti',
		emoji: '\u{1F54A}\uFE0F',
		category: 'national',
		targetCategories: [],
	},
	{
		date: '2026-10-11',
		name: 'Navratri',
		emoji: '\u{1F483}',
		category: 'hindu',
		targetCategories: ['Apparel', 'Jewellery', 'Food'],
	},
	{
		date: '2026-10-21',
		name: 'Dussehra',
		emoji: '\u{1F3F9}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-11-08',
		name: 'Dhanteras',
		emoji: '\u{1F4B0}',
		category: 'hindu',
		targetCategories: ['Jewellery', 'Electronics', 'General Store'],
	},
	{
		date: '2026-11-10',
		name: 'Diwali',
		emoji: '\u{1FA94}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-11-11',
		name: 'Bhai Dooj',
		emoji: '\u{1F381}',
		category: 'hindu',
		targetCategories: [],
	},
	{
		date: '2026-12-25',
		name: 'Christmas',
		emoji: '\u{1F384}',
		category: 'christian',
		targetCategories: [],
	},
	{
		date: '2026-12-31',
		name: 'New Year Eve',
		emoji: '\u{1F386}',
		category: 'national',
		targetCategories: [],
	},
];

export const MAJOR_FESTIVALS: string[] = [
	'Diwali',
	'Holi',
	'Eid ul-Fitr',
	'Navratri',
	'Raksha Bandhan',
];

function toIsoDate(date: Date): string {
	return date.toISOString().split('T')[0] ?? '';
}

/**
 * Returns festivals for a given date, including major-festival reminders 2 days before.
 */
export function getFestivalsForDate(dateStr: string): FestivalWithReminder[] {
	const targetDate = new Date(`${dateStr}T00:00:00.000Z`);
	if (Number.isNaN(targetDate.getTime())) {
		return [];
	}

	const twoDaysLater = new Date(targetDate);
	twoDaysLater.setUTCDate(twoDaysLater.getUTCDate() + 2);
	const twoDaysLaterStr = toIsoDate(twoDaysLater);

	const matches: FestivalWithReminder[] = [];
	for (const festival of FESTIVALS_2026) {
		if (festival.date === dateStr) {
			matches.push({ ...festival, isReminder: false });
			continue;
		}

		if (
			festival.date === twoDaysLaterStr &&
			MAJOR_FESTIVALS.includes(festival.name)
		) {
			matches.push({ ...festival, isReminder: true });
		}
	}

	return matches;
}