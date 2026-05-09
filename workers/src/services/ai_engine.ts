export async function removeBackgroundFromImage(
  imageBase64: string,
  apiKey: string,
): Promise<string> {
  const response = await fetch(
    'https://api.ai-engine.net/v1/remove-background',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({ image: imageBase64 }),
    },
  );

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`AI Engine ${response.status}: ${err}`);
  }

  const data = (await response.json()) as { result?: string };
  if (!data.result) {
    throw new Error('AI Engine response missing result');
  }

  return data.result;
}
