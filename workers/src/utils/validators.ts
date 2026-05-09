const SAFE_SLUG_PATTERN = /^[a-z0-9][a-z0-9-]{1,38}[a-z0-9]$/;

export function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function isSafeSlug(value: string): boolean {
	return SAFE_SLUG_PATTERN.test(value.trim().toLowerCase());
}

export function readTrimmedString(
	value: unknown,
	options: { maxLength?: number; fallback?: string } = {},
): string {
	const fallback = options.fallback ?? '';
	if (typeof value !== 'string') {
		return fallback;
	}

	const trimmed = value.trim();
	if (!trimmed) {
		return fallback;
	}

	if (options.maxLength != null) {
		return trimmed.slice(0, options.maxLength);
	}

	return trimmed;
}

export function readOptionalString(
	value: unknown,
	options: { maxLength?: number } = {},
): string | null {
	const trimmed = readTrimmedString(value, { maxLength: options.maxLength });
	return trimmed ? trimmed : null;
}

export function readPositiveInteger(
	value: unknown,
	options: { min?: number; max?: number; fallback?: number } = {},
): number {
	const min = options.min ?? 1;
	const max = options.max ?? Number.MAX_SAFE_INTEGER;
	const fallback = options.fallback ?? 0;

	if (typeof value !== 'number' || !Number.isFinite(value)) {
		return fallback;
	}

	const parsed = Math.trunc(value);
	if (parsed < min || parsed > max) {
		return fallback;
	}

	return parsed;
}

export function normalizePhone(value: unknown): string {
	const raw = typeof value === 'string' ? value : '';
	const digits = raw.replace(/[^0-9]/g, '');
	if (digits.length === 10) {
		return digits;
	}
	if (digits.length === 12 && digits.startsWith('91')) {
		return digits.slice(2);
	}
	if (digits.length > 10) {
		return digits.slice(digits.length - 10);
	}
	return digits;
}

export function isValidIndianPhone(value: string): boolean {
	return /^[6-9][0-9]{9}$/.test(value);
}

export function isValidUuidLike(value: string): boolean {
	return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
		value.trim(),
	);
}
