# Advent of Code 2025

DataWeave solutions to [adventofcode.com](https://adventofcode.com) puzzles, solved by multiple AIs and compared side by side.

## AIs being compared

- `claude` — Claude (via Claude Code, MAX effort mode — longer think times, higher cost $$$)
- `curietech` — CurieTech (referred to as "Curie" for short)

## Repo structure

```
scripts/
  dayN/
    partN/
      input.txt             ← shared puzzle input (same for all AIs)
      output.txt            ← expected correct answer (same for all AIs)
      claude/transform.dwl
      curietech/transform.dwl
      benchmark/            ← folder name kept as-is for Playground URL compatibility
        inputs/payload.txt  ← copy of input.txt, required by the Playground
        transform.dwl       ← runs both solutions via Timer::time() and compares
```

- `input.txt` and `output.txt` live at the part level, not inside AI folders — they are shared.
- Each AI gets its own subfolder with a `transform.dwl` script.
- The `benchmark/` folder name is kept as-is (not renamed) for DataWeave Playground URL compatibility, even though the README refers to this column as "Exec Time".

## README table

The README tracks progress with a table. Each cell links to the solution file:

```
| Day | Part | Claude | CurieTech | Exec Time | Claude Notes | Curie Notes |
|-----|------|--------|-----------|-----------|-------------|-------------|
| 1 | 1 | [script](scripts/day1/part1/claude/transform.dwl) | [script](scripts/day1/part1/curietech/transform.dwl) | [▶ Open in Playground](...) | | |
```

- The **Exec Time** column links to the DataWeave Playground to run the timing script.
- The **Claude Notes** and **Curie Notes** columns hold observations per AI. Use ❌ for negatives, ✅ for positives.
- Markdown lists don't render inside table cells on GitHub — use plain text or `<br>` with bullet characters if needed.

When adding a new solution:
1. Create the file at `scripts/dayN/partN/<ai>/transform.dwl`
2. Add or update the row in the README table with a `[script](path/to/transform.dwl)` link
3. Update `scripts/dayN/partN/benchmark/transform.dwl` to inline the new solution as a function and wrap it with `time()` alongside the other AI's solution
4. Copy `input.txt` to `scripts/dayN/partN/benchmark/inputs/payload.txt` if not already there

Workflow conventions:
- Don't preemptively scaffold the benchmark, `input.txt`, or `output.txt` when only one AI's solution has been provided. Wait until the user supplies the other AI's script and the puzzle input/output. Only build the benchmark once both AI scripts exist.
- `output.txt` contains just the expected answer (e.g. `17694`) with a trailing newline — no JSON wrapper.
- When a notes cell has multiple bullets, separate with `<br>` and order them chronologically/causally (e.g. "Returned a Python script first" comes before "Wrong answer on the first try").
- Notes apply per AI — if a behavior (e.g. "returned Python first") happened to both, add it to both the Claude Notes and Curie Notes cells.

## Exec Time

Each `benchmark/transform.dwl` uses `dw::util::Timer::time()` to measure the execution time of both AI solutions against the real puzzle input, returning results side by side.

The Playground URL structure is:
```
https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2025&path=scripts%2FdayN%2FpartN%2Fbenchmark
```

The README table has an **Exec Time** column with a **▶ Open in Playground** link for each day/part. Add one when creating a new timing script.

## Claude solutions

Claude solutions are generated using MAX effort mode in Claude Code. This results in extended thinking time and higher API cost.

- Claude does **not** execute the generated DataWeave code — errors are only caught if the script is run externally. This can require a second attempt if the first script has a DW error.
- Per-task cost is not surfaced by Claude Code directly. Check the Anthropic Console usage dashboard for spend.

## CurieTech solutions

CurieTech solutions can be generated two ways:
- Via the **curie-dataweave MCP server** connected to Claude Code over HTTP transport
- Directly in the chat at **platform.curietech.ai**

The `get_task_result` API response does not include cost or credit usage — check the platform dashboard at platform.curietech.ai for credit consumption.

To connect the MCP server:

```sh
claude mcp add --scope user --transport http curie-dataweave https://platform.curietech.ai/mcp/ --header "Authorization: Bearer <your-api-key>"
```

Use `generate_dataweave` to submit a task, then poll with `get_task_result` until status is `DOCUMENT_GENERATED`. Poll every 10s for the first minute, every 20s for 1–3 minutes, every 30s after that.
