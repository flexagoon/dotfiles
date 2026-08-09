import {
  copyToClipboard,
  type ExtensionAPI,
  type ExtensionContext,
  type SessionMessageEntry,
} from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const copyLastUserMessage = async (ctx: ExtensionContext) => {
    const entries = ctx.sessionManager.buildContextEntries();
    const lastUser = [...entries]
      .reverse()
      .find(
        (e): e is SessionMessageEntry =>
          e.type === "message" && e.message.role === "user",
      );

    const text = lastUser ? extractText(lastUser.message) : undefined;
    if (!text) {
      ctx.ui.notify("No user messages to copy yet.", "info");
      return;
    }

    try {
      await copyToClipboard(text);
      ctx.ui.notify("Copied last user message to clipboard", "info");
    } catch (error) {
      ctx.ui.notify(
        `Failed to copy: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  };

  pi.registerCommand("copy-mine", {
    description: "Copy last user message to clipboard",
    handler: async (_args, ctx) => copyLastUserMessage(ctx),
  });

  pi.registerShortcut("ctrl+shift+y", {
    description: "Copy last user message to clipboard",
    handler: async (ctx) => copyLastUserMessage(ctx),
  });
}

// AgentMessage is an open union (apps extend CustomAgentMessages via
// declaration merging), so TS can't narrow it by role. Inspect structurally.
function extractText(message: unknown): string | undefined {
  if (!message || typeof message !== "object") return undefined;
  const m = message as { role?: unknown; content?: unknown };
  if (m.role !== "user") return undefined;

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
    .join("");
  return text.trim() || undefined;
}