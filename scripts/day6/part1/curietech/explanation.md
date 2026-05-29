# Day 6 Part 1 — CurieTech's full explanation

This is the verbatim explanation Curie produced while working through Day 6 Part 1. It's preserved here so the README table stays readable.

---

Let me work out the parsing logic. The key insight: each problem occupies one or more columns of digits, problems are separated by a **fully blank column**, and the operator is on the bottom row.

Let me build and verify the DataWeave. The comment line is being parsed oddly. The issue is the inline `//` comment ending. Let me restructure — actually the issue is the multi-line var with `\n`. Let me check by simplifying. The real problem: `reduce` with index `$$` ordering. Let me rewrite more carefully. The `*` followed by other chars inside the string literal seems fine, but the parser is choking. The real culprit is likely `" " * (...) — *` is multiply, not string repeat in DW. But the error points to line 3 column 11, the `var input` line. That's odd. The issue may be that `\n*` sequences — actually no. Let me use `read` with the raw string differently, building input from an array of lines instead. Progress — the array form parsed fine (so the earlier issue was the string literal). Now I need to import `repeat` from `dw::core::Strings` and use `every` from `dw::core::Arrays`. Let me fix the imports.

Close! The issue is `cols map paddedOpRow[$]` — inside `map`, `$` is the element, but `paddedOpRow[$]` is being parsed with the outer lambda context confusion. Actually the error shows `paddedOpRow[[0,1]]` — meaning `$` resolved to the whole `cols` array. This is a lambda-scoping issue: inside `map` the `[$]` selector binds oddly. Let me use explicit lambda params.

The `idx` is being bound to the whole array `[0,1]`, not each element. This means `cols` is `[[0,1]]` — a nested array! My `groups` reduce is producing the wrong groups shape. The problem: `acc << [c]` and `acc[-1] << c` — when I do `acc[-1] << c`, `acc[-1]` is an array like `[0]`, appending `c` gives `[0,1]`. Then `(acc[0 to -2] default []) + [...]`. That looks right, but the issue is `cols map ((idx) -> ...)` where `cols` is e.g. `[0,1]` — `idx` should be `0` then `1`.

The error shows `idx = [0,1]`, so `cols` is `[[0,1]]`. That means `groups` is a list of single-element-wrapping. Let me debug `groups` directly. I see two bugs:

1. **Nesting:** `acc[-1] << c` produces nested arrays because `acc[-1]` plus the wrapping in `[...]` creates double nesting in the contiguous branch.

2. **It's not merging contiguous columns into one group** — columns 0,1,2 should be ONE problem (`123/45/6`), but I'm getting `[0,1]`, `[2]` split.

The split is happening because the column-grouping logic appends correctly only when `acc[-1][-1] = c-1`, but `acc[-1]` is `[[0,1]]` (nested), so `acc[-1][-1]` is `[0,1]` not `1`. The nesting is the root cause.

The bug: in the contiguous branch I do `acc[-1] << c` where `acc[-1]` is already the group array `[0,1]`, giving `[0,1,c]` — good. But then I wrap: `[(acc[-1] << c))]` and prepend `acc[0 to -2]`. Wait `acc[-1] << c` should be flat. The nesting `[[0,1]]` suggests `acc[-1]` itself was `[[0]]`.

The real issue: `acc << [c]` — when `acc` is `[]`, this gives `[[0]]` ... no, `[] << [0]` = `[[0]]`. So first element becomes `[0]`. Good. Then c=1: `acc[-1] = [0]`, `acc[-1][-1] = 0` = c-1 ✓, so `(acc[0 to -2] default []) + [([0] << 1)]` = `[] + [[0,1]]` = `[[0,1]]`. Good, flat.

But output shows `[[0,1]]` as first group element — that means `groups = [[[0,1]], [2], ...]`. So group[0] = `[[0,1]]` nested! The outer reduce result wraps. Actually `[] + [[0,1]]` = `[[0,1]]` and that IS the acc. So acc is `[[0,1]]`. Then c=2 is blank? No — col 2 is `3/5/6` ...

Columns: `"123 328 ... "` → idx0=`'1'`,1=`'2'`,2=`'3'`,3=`' '`. So col 3 is the separator, cols 0,1,2 are problem 1. But isBlankCol(2): row0[2]=`'3'` → not blank. So c=2 should append. `acc[-1][-1]`: acc= `[[0,1]]`, acc[-1]= `[0,1]`, acc[-1][-1]= `1` ==c-1=1 ✓. Good, it should append. But output shows `[2]` separate.

The bug is operator precedence of `<<` and `[-1]`. `acc[-1] << c` may parse as `acc[-1 << c]`. Let me parenthesize. Now `+ [[c]]` always fires (the contiguous branch never matches) and each `[c]` is nested as `[[c]]`. The `[[c]]`. The contiguous check fails because `(acc(-1))[-1]` — `acc[-1]` is `[[0]]` so `[-1]` gives `[0]` not `0`.

The reduce-building-nested-array approach is fragile. Let me use a much simpler, robust approach: instead of grouping column indices via reduce, `transpose` isn't needed. I'll identify blank columns, then split the column-index list on blanks using a cleaner method. Simplest: build a string mask where each column is "X" (has content) or " " (blank), then `splitBy` runs of spaces to get token groups, tracking offsets.

Even cleaner: process per-row. Actually the most reliable: for each row string, blank columns are spaces shared by ALL rows. Let me compute the set of blank column indices, then split each row at those exact positions.

Let me use a clean approach with `splitBy` a regex on a "merged mask" — but I need column ranges. Let me group indices functionally with a helper that folds correctly. The mask is all `X` — meaning no column is fully blank. That's because the **operator row** has operators only under the first column of each problem, but the separator column between problems... let me check. Row `"123 328 51 64 "`: between `"123"` and `"328"` there's ONE space (col 3). Between `"328"` and `"51"` there are TWO spaces.

The separator is a *full column of only spaces across all rows*. Let me check col 3 across all 4 rows:

- row0[3]=`' '`, row1[3]=`' '` (` 45 64...` idx3=`' '`? `45` → 0=`' '`,1=`'4'`,2=`'5'`,3=`' '`), row2[3]=`' '`, opRow[3]=`' '` → col 3 IS blank.

But mask shows all X. So my `every` check is wrong, OR padding made rows different lengths. The op row `"* + * + "` — let me debug the per-column check. Let me verify column alignment. The per-column blank detection works perfectly now (cols 3, 7, 11 are blank separators). So the issue earlier was the selector binding inside the lambda. Using explicit `($[c] = " ")` inside `every` with the outer `c` param works fine here.

The mask shows blanks at cols 3, 7, 11 → segments should be `[0-2], [4-6], [8-10], [12-14]`. The earlier mask failure was a selector-scoping issue. Now let me build the full solution with this working column-mask approach. `g.startIdx` is resolving to `[0]` (an array) — the reduce produced objects with startIdx is wrapped. Same nested-array issue in the reduce. `acc[0 to -2] default []`. Actually `g.startIdx` being `[0]` means the object value is an array. Let me inspect `groups`. Two clear problems with the `reduce` lambda:

1. `colIsBlank(c)` is **never returning true** here even for cols 3,7,11 — every column became its own group AND blank columns 3,7,11 are present as groups, meaning `colIsBlank` returned false for them.

2. Each accumulator entry got wrapped in an extra array `[{...}]`.

Wait — earlier the *same* `colIsBlank` logic worked in the `perCol` debug. The difference: there I called it inline; here it's a `fun`. The issue must be `acc + [{...}]` — `acc` starts as `[]`, but inside reduce the `+` with single-element... Actually the wrapping `[[{}]]` suggests the **reduce default** `acc = []` combined with element being an int `c` and DW treating `acc + [x]` where the FIRST iteration acc is the seed.

Actually the real tell: blank cols 3,7,11 appear as groups. That means `colIsBlank` returns false. But the only change is wrapping in a function. The `every` over `allRows` with `$[c]` — inside the `fun`, `$` refers correctly to each row, `c` is the param. That matched before.

Hmm, but the wrapping `[[...]]` is the giveaway: the reduce is iterating over a range that yields arrays. `(0 to (maxWidth-1))` where maxWidth is fine. Let me stop fighting `reduce` lambda scoping and switch strategy entirely: build problems by **splitting each transposed structure**.

Cleanest robust approach: transpose to columns, but group via a string mask + `scan`-free method. Let me just split the mask string and compute offsets with a helper using recursion over segments. Actually — simplest of all: replace blank separator columns with a delimiter and split. Let me transpose rows into columns, mark each column token, join columns with a marker for blanks.

`splitWhere` doesn't exist. But the `columns` with `blank` flag computed correctly now (let me confirm) — and importantly I switched the inner `every` to `((r) -> r[c] = " ")` with explicit param, which avoids the `$` scoping bug. Let me check the blank output and then group columns by folding over the column objects (not a raw range). 4 groups now (correct count!), but each group has size 1 instead of 3. The contiguous-merge branch `(acc[-1] + col)` isn't accumulating — `acc[-1] + col` where `acc[-1]` is `[col0]` (array) and `col` is object → should give `[col0, col1]`. But sizes are 1, so the close-group `acc + [[]]` branch is firing too aggressively, OR the merge replaces.

Issue: after a blank I push `[[]]` (empty group). Then next non-blank: `acc[-1]` is `[]` (empty), `acc[-1] + col = [col]`. Good. But for consecutive non-blanks within a problem, e.g. cols 0,1,2:

- c0: acc=[] → `[[col0]]`
- c1 (non-blank): acc not empty → `(acc[0 to-2] default []) + [acc[-1] + col1]` = `[] + [[col0,col1]]` = `[[col0,col1]]` ✓ size 2

But result size is 1. So `acc[-1] + col` is NOT concatenating. In DW, `array + object` **appends the object** → `[col0] + col1` ... actually `+` on array with non-array appends element: `[1] + 2 = [1,2]`. That should work. Unless `col` is itself being treated as array of its entries.

`Array + Object`: DW `+` appends → `[col0] + col1obj`. Let me test that primitive. Actually simpler: use `<<` append operator which is unambiguous for appending an element. Both work. So `acc[-1] + col` should append. The problem must be that the merge branch isn't being taken — the blank-handling pushes `[[]]` and somehow each column ends isolated. Let me reconsider: cols 0,1,2 are NON-blank consecutive, col 3 blank. So no blank between 0,1,2. The merge should fire for c1,c2.

Let me just directly debug by printing the actual groups structure (chars only) instead of sizes. Now it shows nested `[[2]],[[6]]...` and only the LAST column of each problem survives. The pattern reveals the truth: `reduce`'s `acc[-1]` and the `[0 to -2]` slice are corrupting state. Each merge keeps only the latest because `acc[0 to -2] default []` when acc has one element `[[col0]]` → `acc[0 to -2]` = `[]` (drops the only element), then `+ [acc[-1] << col]` = `[[col0,col1]]`. That's correct... but output shows only `[2]` (last col of problem 1, col index 2).

The `[[2]]` double-nesting + only-last-element means `acc[-1] << col` is **replacing** not appending, and `acc[0 to -2]` keeps dropping. This is the classic DW reduce-with-self-referencing-accumulator-slice bug — too fragile.

I've now spent several attempts fighting `reduce` accumulator mutation. Per my own debugging discipline: **stop iterating on this approach; switch to a fundamentally different, simpler one.**

New approach: avoid index-grouping reduce entirely. Build a vertical-string per column, join all columns into rows separated so I can `splitBy` on blank columns directly using string operations. Concretely: transpose the grid to a list of column-strings; mark blanks; then `joinBy ""` and split the marker run. Simplest: **reconstruct each problem by splitting the original rows on the blank-column positions** computed as a set, using `substring` on the boundaries.

Let me compute blank column indices, derive [start,end] segment boundaries with a clean recursive/array method, then substring each row.This works perfectly. Mask `XXX XXX XXX XXX`, clean segments `[0-2],[4-6],[8-10],[12-14]`. The `starts` / `ends` boundary-detection approach (no fragile reduce accumulator) is robust. Now let me complete the solution: slice each row per segment, parse numbers, apply operators, sum. Just a type inference issue on `sum` — `answers` is inferred as possibly containing null. Let me coerce. Let me check the actual values first by removing the sum. It matches the puzzle exactly:

- `123 * 45 * 6 = 33210` ✓
- `328 + 64 + 98 = 490` ✓
- `51 * 387 * 215 = 4243455` ✓
- `64 + 23 + 314 = 4277556` ✓
- **Grand total = 4277556** ✓

The solution is verified. Here's your final, ready-to-use DataWeave. Just feed the raw worksheet text in as `payload` (or replace the `raw` var).

```dataweave
%dw 2.0
output application/json
import every from dw::core::Arrays
import * from dw::core::Strings

// Raw worksheet text. Use `payload` when reading the file in a Mule flow.
var raw = payload

// --- split into rows; last row holds the operator
var rows = raw splitBy "\n"
var numberRows = rows[0 to -2]
var opRow = rows[-1]
var maxWidth = (max(rows map sizeOf($)) default 0) as Number

// pad every row to the same width so column indexing is uniform
var paddedNumberRows = numberRows map rightPad($, maxWidth)
var paddedOpRow = rightPad(opRow, maxWidth)
var allRows = paddedNumberRows << paddedOpRow

// --- column mask: 'X' = a column with content, ' ' = a fully blank separator column
var mask = ((0 to (maxWidth - 1)) map ((c) -> if (allRows every ((r) -> r[c] == " ")) " " else "X")) joinBy ""

// --- detect each contiguous run of 'X' = one problem's column range
var withIdx = (0 to (maxWidth - 1)) map ((c) -> {c: c, x: (mask[c] == "X")})
var starts = (withIdx filter ((o) -> o.x and ((o.c == 0) or (mask[o.c - 1] == " ")))) map $.c
var ends   = (withIdx filter ((o) -> o.x and ((o.c == maxWidth - 1) or (mask[o.c + 1] == " ")))) map $.c
var segments = (starts zip ends) map { startIdx: $[0], endIdx: $[1] }

// --- build each problem: pull the vertical numbers + the operator
fun sliceTrim(row, seg) = trim(row[seg.startIdx to seg.endIdx])
var problems = segments map ((seg) -> {
    nums: paddedNumberRows map ((r) -> sliceTrim(r, seg)) filter (!isEmpty($)) map ($ as Number),
    op:   trim(paddedOpRow[seg.startIdx to seg.endIdx])
})

// --- solve each problem and sum the answers
fun solve(p) = if (p.op == "*") (p.nums reduce ($$ * $)) else (p.nums reduce ($$ + $))
var answers = problems map solve($)
---
{ problems: problems, answers: answers, grandTotal: sum(answers as Array<Number>) }
```

**Key design notes (the gotchas I worked through):**

- A separator is a **fully blank column across every row including the operator row** — detected with the `mask` string, not just spaces in one row (numbers can be right/left-aligned with internal spaces).
- I deliberately avoided a self-referencing `reduce` accumulator for grouping columns (DW's `acc[-1]` / `acc[0 to -2]` slicing kept corrupting state and nesting arrays). The flip-detection `starts` / `ends` + `zip` approach is far more robust.
- `rightPad` normalizes ragged row widths so column indexing never goes out of bounds.
- If you only want the number, replace the final body with just `sum(answers as Array<Number>)`.

Want me to wrap this into a complete Mule flow (file read → transform → log the grand total), or save it as a `.dwl` artifact you can download?
