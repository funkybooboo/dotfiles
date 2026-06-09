/**
 * Ollama Provider Extension
 *
 * Registers local Ollama as an OpenAI-compatible provider.
 * Dynamically fetches available models from the Ollama API.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default async function (pi: ExtensionAPI) {
  const baseUrl = "http://localhost:11434";

  // Try to fetch models; if Ollama isn't running, register with empty list
  // and it'll work when Ollama starts + /reload
  let models: Array<{
    id: string;
    name?: string;
    context_window?: number;
    max_tokens?: number;
  }> = [];

  try {
    const response = await fetch(`${baseUrl}/v1/models`, {
      signal: AbortSignal.timeout(3000),
    });
    if (response.ok) {
      const payload = (await response.json()) as { data: typeof models };
      models = payload.data ?? [];
    }
  } catch {
    // Ollama not running — extension still loads, models available after /reload
  }

  pi.registerProvider("ollama", {
    name: "Ollama (local)",
    baseUrl: `${baseUrl}/v1`,
    api: "openai-completions",
    models: models.map((model) => ({
      id: model.id ?? model.name ?? "unknown",
      name: model.name ?? model.id ?? "unknown",
      reasoning: false,
      input: ["text"],
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
      contextWindow: model.context_window ?? 32768,
      maxTokens: model.max_tokens ?? 4096,
      compat: {
        supportsDeveloperRole: false,
        thinkingFormat: "qwen-chat-template",
      },
    })),
  });
}
