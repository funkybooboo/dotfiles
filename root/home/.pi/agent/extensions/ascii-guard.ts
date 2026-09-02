/**
 * ASCII Guard Extension
 *
 * Enforces the global ASCII-only policy (see AGENTS.md): agents may only
 * write pure ASCII text. Blocks tool calls that would introduce non-ASCII
 * characters (emoji, smart quotes, em/en dashes, ellipsis, accented
 * letters, box-drawing, ...):
 *   - write:    the file content
 *   - edit:     each edits[].newText (oldText is NOT scanned, so converting
 *               existing non-ASCII text to ASCII stays allowed)
 *   - bash:     the command string (covers commit messages, echo, heredocs,
 *               and redirections that would bypass the write/edit checks)
 *   - remember: the memory text
 * Blocked calls return an instructive reason so the model retries in ASCII.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// Anything outside 0x00-0x7F. The /u flag keeps astral characters (emoji)
// as single code points instead of surrogate-pair halves.
const NON_ASCII_RE = /[^\x00-\x7F]/gu;

const MAX_REPORTED = 8;

// Distinct non-ASCII characters, rendered as "<char> (U+XXXX)" for the
// block reason so the model sees exactly what to replace.
function describeNonAscii(text: string): string[] {
  const chars = [...new Set(text.match(NON_ASCII_RE) ?? [])].slice(0, MAX_REPORTED);
  return chars.map((c) => {
    const hex = c.codePointAt(0)!.toString(16).toUpperCase().padStart(4, "0");
    return `${c} (U+${hex})`;
  });
}

// Extract every newText from an edit tool input, tolerating the malformed
// shapes the edit tool itself defends against (edits sent as a JSON string,
// legacy top-level oldText/newText). Fail closed: unparseable input is
// scanned whole so nothing slips through.
function collectNewText(input: unknown): string[] {
  const out: string[] = [];
  if (!input || typeof input !== "object") return out;
  const record = input as Record<string, unknown>;

  let list: unknown[] | null = null;
  if (Array.isArray(record.edits)) {
    list = record.edits;
  } else if (typeof record.edits === "string") {
    try {
      const parsed: unknown = JSON.parse(record.edits);
      list = Array.isArray(parsed) ? parsed : null;
    } catch {
      list = null;
    }
    if (list === null) out.push(record.edits); // fail closed
  }

  for (const e of list ?? []) {
    if (e && typeof (e as Record<string, unknown>).newText === "string") {
      out.push((e as Record<string, unknown>).newText as string);
    }
  }
  if (typeof record.newText === "string") out.push(record.newText);
  return out;
}

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    let where = "";
    let offenders: string[] = [];

    if (isToolCallEventType("write", event)) {
      where = `write "${event.input.path}"`;
      offenders = describeNonAscii(event.input.content);
    } else if (isToolCallEventType("edit", event)) {
      where = `edit "${event.input.path}"`;
      offenders = [...new Set(collectNewText(event.input).flatMap(describeNonAscii))];
    } else if (isToolCallEventType("bash", event)) {
      where = "bash command";
      offenders = describeNonAscii(event.input.command);
    } else if (event.toolName === "remember") {
      const text = (event.input as unknown as { text?: unknown }).text;
      if (typeof text === "string") {
        where = "remember";
        offenders = describeNonAscii(text);
      }
    }

    if (offenders.length === 0) return;

    if (ctx.hasUI) {
      ctx.ui.notify(`Blocked ${where}: non-ASCII characters violate ASCII-only policy`, "warning");
    }
    return {
      block: true,
      reason:
        `Non-ASCII characters detected in ${where}: ${offenders.join(", ")}. ` +
        "Agents may only write pure ASCII in this environment. " +
        "Rewrite with ASCII equivalents: smart quotes -> \" ', em/en dash -> -- or -, " +
        "ellipsis -> ..., accented letters -> base letter, emoji/symbols -> remove or [OK] (x) -> WARNING. " +
        "To grep/sed existing non-ASCII text, use Unicode escapes such as \\u{00E9} instead of literal characters. " +
        "If this file genuinely needs non-ASCII text (e.g. i18n strings or fixtures), ask the user to add it manually.",
    };
  });
}