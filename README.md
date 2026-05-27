# Advent of Code 2025

DataWeave solutions to [adventofcode.com](https://adventofcode.com) puzzles, solved by different AIs and compared.

## Solutions

| Day | Part | Claude | CurieTech | Exec Time | Claude Notes | Curie Notes |
|-----|------|--------|-----------|-----------|-------------|-------------|
| 1 | 1 | [script](scripts/day1/part1/claude/transform.dwl) | [script](scripts/day1/part1/curietech/transform.dwl) | [▶ Open in Playground](https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2025&path=scripts%2Fday1%2Fpart1%2Fbenchmark) | | |
| 1 | 2 | [script](scripts/day1/part2/claude/transform.dwl) | [script](scripts/day1/part2/curietech/transform.dwl) | [▶ Open in Playground](https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2025&path=scripts%2Fday1%2Fpart2%2Fbenchmark) | | ❌ Needed 2 tries (wrong answer first). |
| 2 | 1 | [script](scripts/day2/part1/claude/transform.dwl) | [script](scripts/day2/part1/curietech/transform.dwl) | [▶ Open in Playground](https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2025&path=scripts%2Fday2%2Fpart1%2Fbenchmark) | ❌ Needed 2 tries (DW error — no code execution). | ✅ Uses typed function signatures. |
| 2 | 2 | [script](scripts/day2/part2/claude/transform.dwl) | [script](scripts/day2/part2/curietech/transform.dwl) | [▶ Open in Playground](https://dataweave.mulesoft.com/learn/playground?projectMethod=GHRepo&repo=alexandramartinez%2Fadventofcode-2025&path=scripts%2Fday2%2Fpart2%2Fbenchmark) | | ✅ Uses typed function signatures. |

## How solutions are generated

**Claude** — MAX effort mode in Claude Code, which means longer think times and higher cost ($$$).

**CurieTech** — some solutions are generated via the [curie-dataweave MCP server](https://www.curietech.ai/blog/the-curietech-ai-mcp-server-in-claude-code-and-codex) (connected to Claude Code over HTTP transport), and some are done directly in the chat at [platform.curietech.ai](https://platform.curietech.ai/).

To connect the CurieTech MCP server:

```sh
claude mcp add --scope user --transport http curie-dataweave https://platform.curietech.ai/mcp/ --header "Authorization: Bearer <your-api-key>"
```

## Structure

```
scripts/
  dayN/
    partN/
      input.txt             ← shared input
      output.txt            ← expected output
      claude/transform.dwl
      curietech/transform.dwl
      benchmark/
        inputs/payload.txt  ← same input, copied here for the Playground
        transform.dwl       ← runs both solutions via Timer::time() and compares
```

## Exec Time

Each timing script uses `dw::util::Timer::time()` to measure the execution time of each AI's solution against the real puzzle input, then returns the results side by side. Click any **▶ Open in Playground** link in the table above to run it in your browser.

Output looks like:

```json
{
  "day1-part1": {
    "claude":    { "result": 42, "timeMs": 12 },
    "curietech": { "result": 42, "timeMs": 9  }
  }
}
```

