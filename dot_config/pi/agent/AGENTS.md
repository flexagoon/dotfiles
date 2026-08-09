Always respond in English, no matter the language of the query.

## Code quality

- Write elegant, concise code
- Avoid duplication, but don't over-abstract. The general rule of thumb is to
  think about abstraction when you're doing the same stuff three or more times
- Don't extract stuff into functions just for the sake of it. If a piece of
  code is only used once, it's often better to just leave it there
- If there is a standard library function that does what you need, use it
  instead of writing your own
- Use modern language features, don't worry about backwards compatibility
  unless told otherwise
- When removing any function calls or variable usage, ALWAYS check carefully if
  they're used elsewhere. If not, remove the dead code.
- When the language allows that (eg. Python, but not C), put public functions
  at the top of the file and private functions after them. Functions should be
  arranged in call order.

## Comments

Avoid descriptive comments that just restate what the code does. This includes
"section header" comments. Only add comments when a piece of code is
non-obvious. In the comment, explain *why* the code is doing that, not *what*
it's doing.

## Behavior

Follow the chesterton fence princeple. If there is a piece of code that doesn't
make sense which you believe should be changed, ask the user before removing or
changing it.

**NEVER** make up information about what is in the documentation. Always use
context and tools available to you to look up the actual documentation, or the
`kagi-search` skill if there's no other way.

When the user sends you a link, you must **ALWAYS** read it. Use `curl` for
plain-text files like .json/.md/.csv/etc or `kagi-search` extraction for
regular html websites.

## Language skills

Before interacting with Python code in **any** way, including reading it or
running one-time commands, read the `python` skill file.

For TypeScript, verify `tsc` passes on your changes.
