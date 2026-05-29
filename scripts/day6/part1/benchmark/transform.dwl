%dw 2.0
import time from dw::util::Timer
output application/json
import every from dw::core::Arrays
import * from dw::core::Strings

fun claude() = do {
    var raw = (payload as String) replace /\r/ with ""
    var lines = (raw splitBy "\n") filter ($ != "")

    var maxLen = max(lines map sizeOf($))
    fun padRight(s, n) = if (sizeOf(s) >= n) s else s ++ (((1 to (n - sizeOf(s))) map " ") joinBy "")
    var padded = lines map padRight($, maxLen)
    fun charAt(s, i) = s[i to i] default " "

    var colIsSep = (0 to (maxLen - 1)) map (c) -> padded every (charAt($, c) == " ")

    var blockStarts = (0 to (maxLen - 1)) filter ((c) ->
        !colIsSep[c] and (c == 0 or colIsSep[c - 1])
    )
    var blockEnds = (0 to (maxLen - 1)) filter ((c) ->
        !colIsSep[c] and (c == (maxLen - 1) or colIsSep[c + 1])
    )

    var numRows = sizeOf(padded) - 1

    var problems = (0 to (sizeOf(blockStarts) - 1)) map ((i) -> do {
        var s  = blockStarts[i]
        var e  = blockEnds[i]
        var op   = trim(padded[numRows][s to e])
        var nums = (0 to (numRows - 1)) map ((r) -> trim(padded[r][s to e]) as Number)
        ---
        if (op == "*") (nums reduce ($$ * $)) else (nums reduce ($$ + $))
    })
    ---
    sum(problems)
}

fun curietech() = do {
    var raw = payload

    var rows        = raw splitBy "\n"
    var numberRows  = rows[0 to -2]
    var opRow       = rows[-1]
    var maxWidth    = (max(rows map sizeOf($)) default 0) as Number

    var paddedNumberRows = numberRows map rightPad($, maxWidth)
    var paddedOpRow      = rightPad(opRow, maxWidth)
    var allRows          = paddedNumberRows << paddedOpRow

    var mask = ((0 to (maxWidth - 1)) map ((c) ->
        if (allRows every ((r) -> r[c] == " ")) " " else "X")) joinBy ""

    var withIdx = (0 to (maxWidth - 1)) map ((c) -> { c: c, x: (mask[c] == "X") })
    var starts  = (withIdx filter ((o) -> o.x and ((o.c == 0) or (mask[o.c - 1] == " ")))) map $.c
    var ends    = (withIdx filter ((o) -> o.x and ((o.c == maxWidth - 1) or (mask[o.c + 1] == " ")))) map $.c
    var segments = (starts zip ends) map { startIdx: $[0], endIdx: $[1] }

    fun sliceTrim(row, seg) = trim(row[seg.startIdx to seg.endIdx])
    var problems = segments map ((seg) -> {
        nums: (paddedNumberRows map ((r) -> sliceTrim(r, seg))) filter (!isEmpty($)) map ($ as Number),
        op:   trim(paddedOpRow[seg.startIdx to seg.endIdx])
    })

    fun solve(p) = if (p.op == "*") (p.nums reduce ($$ * $)) else (p.nums reduce ($$ + $))
    var answers = problems map solve($)
    ---
    sum(answers as Array<Number>)
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day6-part1": {
        claude: {
            result:  claudeResult.result,
            timeMs:  claudeResult.end - claudeResult.start
        },
        curietech: {
            result:  curietechResult.result,
            timeMs:  curietechResult.end - curietechResult.start
        }
    }
}
