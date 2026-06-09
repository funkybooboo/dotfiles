/**
 * Permissions Extension
 *
 * Enforces critical deny rules for read, edit, and bash operations.
 * Trimmed from OpenCode config — only essential protections.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

// Paths that must never be read
const READ_DENIED_PATTERNS = [
  /\.env$/,
  /\.env\./,
  /\.env\.local$/,
  /\.env\.production$/,
  /\.env\.development$/,
  /\.env\.test$/,
  /\.pem$/,
  /\.key$/,
  /\.p12$/,
  /\.pfx$/,
  /\.cer$/,
  /\.crt$/,
  /\/secrets\//,
  /\/credentials\//,
  /credentials.*\.json$/,
  /secret.*\.json$/,
  /secret.*\.ya?ml$/,
  /\btoken\b/,
  /\bbearer\b/,
  /password.*\.txt$/,
  /passwd.*\.txt$/,
  /\/\.aws\/credentials$/,
  /\/\.aws\/config$/,
  /\/\.kube\/config$/,
  /\/\.ssh\/id_/,
  /\/\.ssh\/.*_rsa/,
  /\/\.ssh\/.*_dsa/,
  /\/\.ssh\/.*_ecdsa/,
  /\/\.ssh\/.*_ed25519/,
  /\/\.gnupg\//,
  /\.npmrc$/,
  /\.pypirc$/,
  /\/auth\.json$/,
  /\.netrc$/,
  /\.git-credentials$/,
  /\/master\.key$/,
  /id_rsa$/,
  /id_dsa$/,
  /id_ecdsa$/,
  /id_ed25519$/,
];

// Paths that must never be edited/written
const EDIT_DENIED_PATTERNS = [
  /\/\.git\//,
  /\/node_modules\//,
  /package-lock\.json$/,
  /yarn\.lock$/,
  /pnpm-lock\.yaml$/,
  /bun\.lockb$/,
  /Cargo\.lock$/,
  /Gemfile\.lock$/,
  /poetry\.lock$/,
  /composer\.lock$/,
  /Pipfile\.lock$/,
];

// Bash command patterns that are always denied
const BASH_DENIED_PATTERNS = [
  /\bdd\s/,
  /\bmkfs/,
  /\bfdisk/,
  /\bparted/,
  /> \/dev\//,
  /\bchmod\s+777/,
  /\bchown\s+root/,
];

// Bash command patterns that require confirmation
const BASH_CONFIRM_PATTERNS = [
  /\brm\s/,
  /\brm\s+-rf/,
];

function matchesAny(path: string, patterns: RegExp[]): boolean {
  return patterns.some((p) => p.test(path));
}

export default function (pi: ExtensionAPI) {
  // Block reads to sensitive files
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("read", event)) {
      const path = event.input.path;
      if (matchesAny(path, READ_DENIED_PATTERNS)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Blocked read: ${path}`, "warning");
        }
        return { block: true, reason: `Reading "${path}" is denied (sensitive file)` };
      }
    }
  });

  // Block edits/writes to protected paths
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("edit", event) || isToolCallEventType("write", event)) {
      const path = event.input.path;
      if (matchesAny(path, EDIT_DENIED_PATTERNS)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Blocked write: ${path}`, "warning");
        }
        return { block: true, reason: `Writing to "${path}" is denied (protected path)` };
      }
      // Also block writes to read-denied paths
      if (matchesAny(path, READ_DENIED_PATTERNS)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Blocked write: ${path}`, "warning");
        }
        return { block: true, reason: `Writing to "${path}" is denied (sensitive file)` };
      }
    }
  });

  // Block or confirm dangerous bash commands
  pi.on("tool_call", async (event, ctx) => {
    if (isToolCallEventType("bash", event)) {
      const command = event.input.command;

      if (matchesAny(command, BASH_DENIED_PATTERNS)) {
        if (ctx.hasUI) {
          ctx.ui.notify(`Blocked command: ${command}`, "warning");
        }
        return { block: true, reason: `Command denied: "${command}"` };
      }

      if (matchesAny(command, BASH_CONFIRM_PATTERNS)) {
        if (ctx.hasUI) {
          const ok = await ctx.ui.confirm(
            "Destructive command",
            `Allow: ${command}?`
          );
          if (!ok) {
            ctx.ui.notify("Command cancelled", "info");
            return { block: true, reason: "User denied destructive command" };
          }
        }
      }
    }
  });
}
