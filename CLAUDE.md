# Advent of Code 2025

DataWeave solutions to [adventofcode.com](https://adventofcode.com) puzzles, solved by multiple AIs and compared side by side.

## AIs being compared

- `claude` — Claude (via Claude Code, MAX effort mode — longer think times, higher cost $$$)
- `curietech` — CurieTech

## Repo structure

```
scripts/
  dayN/
    partN/
      input.txt             ← shared puzzle input (same for all AIs)
      output.txt            ← expected correct answer (same for all AIs)
      claude/transform.dwl
      curietech/transform.dwl
```

- `input.txt` and `output.txt` live at the part level, not inside AI folders — they are shared.
- Each AI gets its own subfolder with a `transform.dwl` script.
- No `inputs/` folder — that was from the old DataWeave Playground setup which is no longer used.

## README table

The README tracks progress with a table. Each cell links to the solution file and shows think time where known:

```
| Day | Part | Claude | CurieTech |
|-----|------|--------|-----------|
| 1 | 1 | [✅ 46s](scripts/day1/part1/claude/transform.dwl) | |
```

When adding a new solution:
1. Create the file at `scripts/dayN/partN/<ai>/transform.dwl`
2. Add or update the row in the README table with a checkmark and think time if known

## Claude solutions

Claude solutions are generated using MAX effort mode in Claude Code. This results in extended thinking time and higher API cost. Think times are recorded in the README table next to each checkmark.

## CurieTech solutions

CurieTech solutions are generated via the curie-dataweave MCP server, connected to Claude Code over HTTP transport. Use `generate_dataweave` to submit a task, then poll with `get_task_result` until it completes.

To connect the MCP server:

```sh
claude mcp add --scope user --transport http curie-dataweave https://platform.curietech.ai/mcp/ --header "Authorization: Bearer <your-api-key>"
```
