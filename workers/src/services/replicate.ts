interface PredictionResponse {
  id: string;
  status: 'starting' | 'processing' | 'succeeded' | 'failed' | 'canceled';
  output?: string[];
  error?: string;
}

export async function generateWithFluxSchnell(
  prompt: string,
  apiToken: string,
): Promise<string> {
  const createRes = await fetch(
    'https://api.replicate.com/v1/models/black-forest-labs/flux-schnell/predictions',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiToken}`,
        'Content-Type': 'application/json',
        Prefer: 'respond-async',
      },
      body: JSON.stringify({
        input: {
          prompt,
          aspect_ratio: '1:1',
          output_format: 'jpeg',
          output_quality: 80,
          num_inference_steps: 4,
        },
      }),
    },
  );

  if (!createRes.ok) {
    const err = await createRes.text();
    throw new Error(`Replicate create failed: ${createRes.status} ${err}`);
  }

  const prediction = (await createRes.json()) as PredictionResponse;

  for (let i = 0; i < 15; i++) {
    await delay(2000);

    const pollRes = await fetch(
      `https://api.replicate.com/v1/predictions/${prediction.id}`,
      {
        headers: { Authorization: `Bearer ${apiToken}` },
      },
    );

    if (!pollRes.ok) {
      const err = await pollRes.text();
      throw new Error(`Replicate poll failed: ${pollRes.status} ${err}`);
    }

    const result = (await pollRes.json()) as PredictionResponse;

    if (result.status === 'succeeded' && result.output?.[0]) {
      return result.output[0];
    }

    if (result.status === 'failed' || result.status === 'canceled') {
      throw new Error(
        `Replicate generation ${result.status}: ${result.error ?? 'unknown'}`,
      );
    }
  }

  throw new Error('Replicate timeout: generation exceeded 30 seconds');
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
