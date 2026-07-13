# claude-html-diagram

A Claude Code plugin that turns a system description into **one self-contained,
interactive HTML architecture diagram** — a full-screen SVG with clickable nodes
and animated request flows. Token-efficient: the CSS, generic JS, and logo are
inlined by a shell step and never pass through the model's tokens.

The final deliverable is a single `.html` file with **no network dependency**.

## Variants (by branch)

This repo ships two variants from the same code — they differ only in the logo:

| Branch          | Variant            | Logo                    |
| --------------- | ------------------ | ----------------------- |
| `master`        | Brand-neutral      | Empty / transparent     |
| `cf`            | Creative Force     | CF logo                 |

## Install

**Brand-neutral (default `master`):**

```
/plugin marketplace add phamvietdung/claude-html-diagram
/plugin install claude-html-diagram@claude-html-diagram
```

**Creative Force branded (`cf` branch):**

```
/plugin marketplace add phamvietdung/claude-html-diagram@cf
/plugin install claude-html-diagram@claude-html-diagram
```

> Both variants share the same marketplace name (`claude-html-diagram`) and plugin
> name (`claude-html-diagram`) — add **one** of the two, not both, since they
> collide on name. To switch variants, remove the marketplace first:
> `/plugin marketplace remove claude-html-diagram`, then add the other branch.

## Usage

Once installed, invoke the skill and describe the system to diagram. It:

1. Copies a scaffold into a temp dir (zero tokens).
2. You edit only the diagram-specific parts (SVG + `DETAIL` / `FLOWS` data).
3. A shell step (`assemble.sh` on macOS/Linux, `assemble.ps1` on Windows) inlines
   the stylesheet, JS, and logo into a single `<name>.html` — the **only** file
   left in your workspace.

Works on both Windows (PowerShell) and macOS/Linux (bash).

## Maintainer note

`master` and `cf` differ by exactly one file:
`plugins/claude-html-diagram/skills/claude-html-diagram/references/logo.svg`.
Apply every other change to both branches to keep them in sync.
