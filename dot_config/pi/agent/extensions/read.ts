import { spawnSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
  SessionMessageEntry,
} from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("read", {
    description: "Render the last assistant message as HTML to a temp file",
    handler: async (_args, ctx) => openLastAssistant(ctx),
  });
}

async function openLastAssistant(ctx: ExtensionContext): Promise<void> {
  const markdown = lastAssistantText(ctx);
  if (!markdown) {
    ctx.ui.notify("No assistant message to read yet.", "info");
    return;
  }

  const html = renderHtml(markdown);
  if (!html) {
    ctx.ui.notify("pandoc is required but failed to run.", "error");
    return;
  }

  const file = join(tmpdir(), `pi-read-${Date.now()}.html`);
  writeFileSync(file, html);

  ctx.ui.notify(`Generated html in ${file}|`, "info");
}

function lastAssistantText(ctx: ExtensionContext): string | undefined {
  const entries = ctx.sessionManager.getBranch();
  const last = [...entries]
    .reverse()
    .find(
      (e): e is SessionMessageEntry =>
        e.type === "message" && e.message.role === "assistant",
    );
  const text = last ? extractText(last.message) : undefined;
  return text && text.trim() ? text : undefined;
}

// AgentMessage is an open union (apps extend CustomAgentMessages via
// declaration merging), so TS can't narrow it by role. Inspect structurally.
function extractText(message: unknown): string | undefined {
  if (!message || typeof message !== "object") return undefined;
  const m = message as { role?: unknown; content?: unknown };
  if (m.role !== "assistant") return undefined;

  const { content } = m;
  if (typeof content === "string") return content.trim() || undefined;
  if (!Array.isArray(content)) return undefined;

  const text = content
    .filter(
      (p): p is { type: "text"; text: string } =>
        !!p &&
        typeof p === "object" &&
        (p as { type?: unknown }).type === "text" &&
        typeof (p as { text?: unknown }).text === "string",
    )
    .map((p) => p.text)
    .join("\n\n");
  return text.trim() || undefined;
}

const CSS = `<style>
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
  max-width: 48rem;
  margin: 2rem auto;
  padding: 0 1rem;
  line-height: 1.6;
  color: #1f2328;
  background: #fff;
}
pre {
  background: #f6f8fa;
  padding: 1rem;
  overflow-x: auto;
  border-radius: 6px;
}
code {
  font-family: "SFMono-Regular", Consolas, monospace;
  font-size: 0.9em;
}
pre code {
  background: none;
  padding: 0;
}
p code, li code {
  background: #f6f8fa;
  padding: 0.15em 0.4em;
  border-radius: 4px;
}
blockquote {
  border-left: 4px solid #d8dee4;
  margin: 1rem 0;
  padding: 0 1rem;
  color: #656d76;
}
table {
  border-collapse: collapse;
  margin: 1rem 0;
}
th, td {
  border: 1px solid #d8dee4;
  padding: 0.4rem 0.8rem;
}
img {
  max-width: 100%;
}
</style>`;

function renderHtml(markdown: string): string | undefined {
  const style = join(tmpdir(), "pi-read-style.css");
  writeFileSync(style, CSS);

  let result;
  try {
    result = spawnSync(
      "pandoc",
      ["-f", "markdown", "-t", "html5", "--standalone", "--include-in-header", style],
      {
        input: markdown,
        encoding: "utf8",
      },
    );
  } catch {
    return undefined;
  }
  if (result.error || result.status !== 0) return undefined;
  return result.stdout;
}