%dw 2.0
output application/json
import every from dw::core::Arrays

var raw = (payload as String) replace /\r/ with ""
var lines = (raw splitBy "\n") filter ($ != "")

var maxLen = max(lines map sizeOf($))
fun padRight(s, n) = if (sizeOf(s) >= n) s else s ++ (((1 to (n - sizeOf(s))) map " ") joinBy "")
var padded = lines map padRight($, maxLen)
fun charAt(s, i) = s[i to i] default " "

// Separator columns are columns that are entirely spaces in every row
var colIsSep = (0 to (maxLen - 1)) map (c) -> padded every (charAt($, c) == " ")

// Problem blocks = runs of consecutive non-separator columns
var blockStarts = (0 to (maxLen - 1)) filter ((c) ->
    !colIsSep[c] and (c == 0 or colIsSep[c - 1])
)
var blockEnds = (0 to (maxLen - 1)) filter ((c) ->
    !colIsSep[c] and (c == (maxLen - 1) or colIsSep[c + 1])
)

var numRows = sizeOf(padded) - 1   // last row holds operators

// In Part 2, each COLUMN of a block is a single number,
// digits MSB→LSB top-to-bottom (leading spaces = padding).
var problems = (0 to (sizeOf(blockStarts) - 1)) map ((i) -> do {
    var s  = blockStarts[i]
    var e  = blockEnds[i]
    var op = trim(padded[numRows][s to e])
    var nums = (s to e) map ((c) ->
        trim(((0 to (numRows - 1)) map ((r) -> charAt(padded[r], c))) joinBy "")
    ) filter ($ != "") map ($ as Number)
    ---
    if (op == "*") (nums reduce ($$ * $)) else (nums reduce ($$ + $))
})
---
sum(problems)
