/**
 * Ollama Provider Extension
 *
 * Registers local Ollama as an OpenAI-compatible provider.
 * Dynamically fetches available models from the Ollama API.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const baseUrl = "http://localhost:11434";

  // Try to fetch models; if Ollama isn't running, skip registration
  let models: Array<{ id: string; name?: string }> = [];

  try {
    const response = await fetch(`${baseUrl}/v1/models`, {
      signal: AbortSignal.timeout(3000),
    });
    if (response.ok) {
      const payload = (await response.json()) as { data: typeof models };
      models = payload.data ?? [];
    }
  } catch {
    // Ollama not running — skip provider registration entirely
  }

  if (models.length === 0) return;

  pi.registerProvider("ollama", {
    name: "Ollama (local)",
    baseUrl: `${baseUrl}/v1`,
    apiKey: "ollama", // Ollama needs no real key, but pi requires the field
    api: "openai-completions",
    models: models.map((model) => ({
      id: model.id ?? model.name ?? "unknown",
      name: model.name ?? model.id ?? "unknown",
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: 32768,
      maxTokens: 4096,
    })),
  });
}
