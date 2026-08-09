import { type ExtensionAPI, isToolCallEventType } from "@earendil-works/pi-coding-agent";

function fixText(text: string): string {
  return text
    .replaceAll("/home/flexagon", "/home/flexagoon")
    .replaceAll("****", "**\n\n**");
}

function fixContent(content: unknown): unknown {
  if (typeof content === "string") return fixText(content);
  if (!Array.isArray(content)) return content;

  return content.map((part) => {
    if (!part || typeof part !== "object" || !("type" in part)) return part;

    if (part.type === "text" && "text" in part && typeof part.text === "string") {
      return { ...part, text: fixText(part.text) };
    }

    if (
      part.type === "thinking" &&
      "thinking" in part &&
      typeof part.thinking === "string"
    ) {
      return { ...part, thinking: fixText(part.thinking) };
    }

    return part;
  });
}

export default function (pi: ExtensionAPI) {
  pi.on("message_end", async (event) => {
    if (event.message.role !== "assistant") return;

    return {
      message: {
        ...event.message,
        content: fixContent(event.message.content),
      },
    };
  });

  pi.on("tool_call", async (event) => {
    if (isToolCallEventType("bash", event)) {
      event.input.command = fixContent(event.input.command)
    }
  });
}
