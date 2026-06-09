/**
 * Lightweight Memory Extension
 *
 * Provides cross-session memory via a simple JSON file.
 * Two tools: `remember` (save facts) and `recall` (search facts).
 * Auto-injects recent memories at session start via before_agent_start.
 *
 * Storage: ~/.pi/agent/memory.json
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

interface Memory {
  text: string;
  timestamp: number;
  tags: string[];
}

interface MemoryStore {
  memories: Memory[];
}

const MEMORY_FILE = path.join(os.homedir(), ".pi", "agent", "memory.json");
const MAX_AUTO_INJECT = 10; // Max recent memories to auto-inject

function loadStore(): MemoryStore {
  try {
    const data = fs.readFileSync(MEMORY_FILE, "utf-8");
    return JSON.parse(data) as MemoryStore;
  } catch {
    return { memories: [] };
  }
}

function saveStore(store: MemoryStore): void {
  fs.writeFileSync(MEMORY_FILE, JSON.stringify(store, null, 2), "utf-8");
}

export default function (pi: ExtensionAPI) {
  // Register `remember` tool — save a fact
  pi.registerTool({
    name: "remember",
    label: "Remember",
    description:
      "Save a fact, decision, or context for future sessions. Use to persist important information across conversations.",
    promptSnippet: "Save important facts with remember",
    promptGuidelines: [
      "Use remember when the user shares a preference, decision, or fact worth retaining across sessions.",
      "Use tags to categorize memories for easier recall later.",
    ],
    parameters: Type.Object({
      text: Type.String({
        description: "The fact or piece of information to remember",
      }),
      tags: Type.Optional(
        Type.Array(Type.String(), {
          description: "Tags for categorization (e.g., ['preference', 'project-x'])",
        })
      ),
    }),
    async execute(_toolCallId, params) {
      const store = loadStore();
      const memory: Memory = {
        text: params.text,
        timestamp: Date.now(),
        tags: params.tags ?? [],
      };
      store.memories.push(memory);
      saveStore(store);

      return {
        content: [{ type: "text", text: `Remembered: "${params.text}"` }],
        details: { tags: memory.tags },
      };
    },
  });

  // Register `recall` tool — search memories
  pi.registerTool({
    name: "recall",
    label: "Recall",
    description:
      "Search saved memories from previous sessions. Use to recall preferences, decisions, or context.",
    promptSnippet: "Search past memories with recall",
    promptGuidelines: [
      "Use recall when context from previous sessions might be relevant to the current task.",
    ],
    parameters: Type.Object({
      query: Type.Optional(
        Type.String({
          description: "Search query — matches against memory text and tags",
        })
      ),
      limit: Type.Optional(
        Type.Number({
          default: 10,
          description: "Max results to return",
        })
      ),
    }),
    async execute(_toolCallId, params) {
      const store = loadStore();
      let results = store.memories;

      if (params.query) {
        const q = params.query.toLowerCase();
        results = results.filter(
          (m) =>
            m.text.toLowerCase().includes(q) ||
            m.tags.some((t) => t.toLowerCase().includes(q))
        );
      }

      // Most recent first
      results = results.reverse().slice(0, params.limit ?? 10);

      if (results.length === 0) {
        return {
          content: [{ type: "text", text: "No memories found." }],
          details: {},
        };
      }

      const lines = results.map((m, i) => {
        const date = new Date(m.timestamp).toISOString().split("T")[0];
        const tags = m.tags.length > 0 ? ` [${m.tags.join(", ")}]` : "";
        return `${i + 1}. (${date}${tags}) ${m.text}`;
      });

      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { count: results.length },
      };
    },
  });

  // Auto-inject recent memories at session start
  pi.on("before_agent_start", async (_event, _ctx) => {
    const store = loadStore();
    if (store.memories.length === 0) return;

    const recent = store.memories
      .slice(-MAX_AUTO_INJECT)
      .reverse()
      .map((m) => {
        const date = new Date(m.timestamp).toISOString().split("T")[0];
        const tags = m.tags.length > 0 ? ` [${m.tags.join(", ")}]` : "";
        return `- (${date}${tags}) ${m.text}`;
      });

    const memoryBlock = `\n## Recent Memories\n${recent.join("\n")}\n`;

    return {
      message: {
        customType: "memory-context",
        content: memoryBlock,
        display: false,
      },
    };
  });
}
