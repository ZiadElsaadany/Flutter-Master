# AI in Development — Interview Questions

## 1. AI Rules and AI Skills

### Question

> AI is now part of our work. Have you heard of AI rules and AI skills? How do you use
> AI?

### Answer

- **AI rules:** persistent project instructions that a coding agent reads on every
  task: your architecture (screen → Cubit → use case → repository → data source),
  state management, naming, folder structure, lint rules, "don't add packages without
  asking". Each tool expects them in a specific file: `CLAUDE.md` (Claude Code),
  `AGENTS.md`, `.github/copilot-instructions.md` (Copilot), Cursor rules. You write
  them once and stop re-explaining the project in every prompt.
- **AI skills:** packaged instructions **plus examples** for one specific kind of task
  (for example "build a responsive screen with `LayoutBuilder`" or "add a feature
  following our clean architecture"). The agent loads a skill only when the task needs
  it.

Flutter's docs have an **"AI rules for Flutter and Dart"** page
(docs.flutter.dev/ai/ai-rules) with a ready rules file in several sizes. It says rules
set the default behavior for all tasks, while skills give instructions for specific
tasks. Adapt it before using it: the template prefers built-in state management and
avoids Bloc/Riverpod unless you ask.

Tools to name: Gemini in Android Studio, GitHub Copilot, Cursor, Windsurf, Claude Code,
Codex, and the **Dart & Flutter MCP server**, which lets agents run analysis, tests and
pub commands.

How I use AI: generating boilerplate (models, tests), explaining unfamiliar code,
drafting a screen from a description. I always review the output (question 3).

### Mental model

Rules = the team handbook (always on). Skills = recipes (loaded when needed).

### Common mistake

The candidate said "I have trouble with names" and only described pasting prompts into
an external chat. The terms **rules**, **skills** and **agent** are exactly what this
question checks.

### Quick revision

Rules: always-on project conventions in `CLAUDE.md` / `AGENTS.md` / Copilot
instructions. Skills: task-specific instructions + examples, loaded on demand. Flutter
publishes a starter rules file.

## 2. Context in AI Tools

### Question

> Have you heard of "context" in the AI world (not Flutter's `BuildContext`)?

### Answer

**Context** is everything the model can see when it answers: your prompt, the
conversation so far, files it read, rules and skills, and tool output (test results,
errors). It is limited by the **context window**, measured in **tokens**.

Why it matters:

- **Quality:** the right files and rules → code that fits your project. Too much
  irrelevant context → worse answers.
- **Cost and speed:** more tokens cost more and run slower.

Good habits: point the agent at the exact files, keep rules short, start a new session
for each unrelated task, and give it a way to check itself (`flutter analyze`, tests).
Managing this deliberately is called **context engineering**.

### Mental model

Context is the model's short-term memory for this task. Fill it with what matters.

### Common mistake

The candidate only knew Flutter's `BuildContext`. In AI tools, "context" means the
model's input.

### Quick revision

Context = everything the model sees (prompt, files, rules, tool output), limited by
the context window in tokens. Relevant and small = better and cheaper.

## 3. Accepting or Rejecting AI-Generated Code

### Question

> You ask an AI tool for a screen and it gives you a file. The UI matches the Figma.
> On what criteria do you accept the code, or ask it to change it?

### Answer

Review it like a **teammate's pull request**. "It looks right" isn't enough:

- **Architecture:** follows our layers and state management. No API calls or business
  logic in widgets.
- **Correctness:** loading, empty and error states. Null safety. Edge cases (long text,
  RTL/Arabic, small screens).
- **Performance:** `const` where possible, builder lists, no work in `build`, no
  unnecessary rebuilds.
- **Resources:** controllers, streams and subscriptions **disposed** (no memory leaks).
- **Conventions:** theme colors and text styles instead of hardcoded values,
  localization instead of hardcoded strings, no new packages without a reason.
- **Checks pass:** `flutter analyze` clean, tests pass (or added).
- **I understand every line.** If I can't explain it, I don't merge it.

### Mental model

AI writes the first draft. You are still the author.

### Common mistake

The candidate mentioned performance and possible problems later. That's good, but make
the list concrete: architecture, states, rebuilds, `dispose`, theme/l10n, analyze and
tests.

### Quick revision

Accept only if it fits the architecture, handles all states, performs well, disposes
resources, follows conventions, passes analyze and tests, and you understand it.
