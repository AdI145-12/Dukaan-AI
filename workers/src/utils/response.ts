import { corsHeaders } from '../middleware/cors';

export function jsonSuccess(data: unknown, status = 200): Response {
	return new Response(
		JSON.stringify({ success: true, data }),
		{
			status,
			headers: {
				...corsHeaders,
				'Content-Type': 'application/json',
			},
		},
	);
}

export function jsonError(message: string, status = 400): Response {
	return new Response(
		JSON.stringify({ success: false, error: message }),
		{
			status,
			headers: {
				...corsHeaders,
				'Content-Type': 'application/json',
			},
		},
	);
}