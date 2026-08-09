import {
  type ExtensionAPI,
  type SessionMessageEntry,
} from "@earendil-works/pi-coding-agent";

type ContentPart =
  | { type: "text"; text: string }
  | { type: "image"; data: string; mimeType: string };
type SendableContent = string | ContentPart[];

export default function (pi: ExtensionAPI) {
  pi.registerCommand("retry", {
    description:
      "Go back to your last message and re-send it to regenerate the response",
    handler: async (_args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify(
          "Agent is busy. Abort or wait before retrying.",
          "warning",
        );
        return;
      }

      // getBranch() returns the active path root -> leaf, so the last user
      // message in this array is the most recent one on the current branch.
      const entries = ctx.sessionManager.getBranch();
      let lastUser: SessionMessageEntry | undefined;
      for (let i = entries.length - 1; i >= 0; i--) {
        const entry = entries[i];
        if (entry.type === "message" && entry.message.role === "user") {
          lastUser = entry;
          break;
        }
      }

      if (!lastUser) {
        ctx.ui.notify("No user message to retry.", "info");
        return;
      }

      const content = extractContent(lastUser.message);
      if (!content) {
        ctx.ui.notify("Last user message has no content.", "warning");
        return;
      }

      // Only branch back when there's a real response to preserve. If the
      // only thing after the last user message is an error (or nothing at
      // all), re-send in place instead of creating a dead sibling branch.
      const lastUserIndex = entries.indexOf(lastUser);
      const hasRealResponse = entries
        .slice(lastUserIndex + 1)
        .some((e) => e.type === "message" && hasAssistantContent(e.message));

      if (hasRealResponse) {
        const result = await ctx.navigateTree(lastUser.id, { summarize: false });
        if (result.cancelled) {
          ctx.ui.notify("Retry cancelled.", "info");
          return;
        }
      }

      pi.sendUserMessage(content);
    },
  });
}

// An assistant message counts as a real response worth preserving if it
// produced any text, thinking, or tool calls. Error responses carry an empty
// content array (the failure is in errorMessage), so they are skipped to
// avoid leaving a dead branch.
function hasAssistantContent(message: unknown): boolean {
  if (!message || typeof message !== "object") return false;
  const m = message as { role?: unknown; content?: unknown };
  if (m.role !== "assistant") return false;
  if (!Array.isArray(m.content)) return false;
  return m.content.some((part) => {
    if (!part || typeof part !== "object") return false;
    const p = part as { type?: unknown };
    if (p.type === "toolCall") return true;
    if (p.type === "text" && (part as { text?: string }).text !== "") return true;
    if (p.type === "thinking" && (part as { thinking?: string }).thinking !== "")
      return true;
    return false;
  });
}

// AgentMessage is an open union (extensions extend it via declaration merging),
// so TS can't narrow it by role. Inspect structurally and rebuild the content
// in the shape sendUserMessage accepts.
function extractContent(message: unknown): SendableContent | undefined {
  if (!message || typeof message !== "object") return undefined;
  const msg = message as { role?: unknown; content?: unknown };
  if (msg.role !== "user") return undefined;

  const { content } = msg;
  if (typeof content === "string") return content.trim() || undefined;
  if (!Array.isArray(content)) return undefined;

  const parts: ContentPart[] = [];
  for (const part of content) {
    if (!part || typeof part !== "object") continue;
    const p = part as { type?: unknown };
    if (p.type === "text" && typeof (part as { text?: unknown }).text === "string") {
      parts.push({ type: "text", text: (part as { text: string }).text });
    } else if (
      p.type === "image" &&
      typeof (part as { data?: unknown }).data === "string" &&
      typeof (part as { mimeType?: unknown }).mimeType === "string"
    ) {
      parts.push({
        type: "image",
        data: (part as { data: string }).data,
        mimeType: (part as { mimeType: string }).mimeType,
      });
    }
  }
  return parts.length > 0 ? parts : undefined;
}