%dw 2.0
output application/json
import every from dw::core::Arrays
import * from dw::core::Strings

// Raw worksheet text. Use `payload` when reading the file in a Mule flow.
var raw = payload

// --- split into rows; last row holds the operators ---
var rows        = raw splitBy "\n"
var numberRows  = rows[0 to -2]
var opRow       = rows[-1]
var maxWidth    = (max(rows map sizeOf($)) default 0) as Number

// pad every row to the same width so column indexing is uniform
var paddedNumberRows = numberRows map rightPad($, maxWidth)
var paddedOpRow      = rightPad(opRow, maxWidth)
var allRows          = paddedNumberRows << paddedOpRow

// --- column mask: 'X' = column with content, ' ' = fully blank separator column ---
var mask = ((0 to (maxWidth - 1)) map ((c) ->
    if (allRows every ((r) -> r[c] == " ")) " " else "X")) joinBy ""

// --- detect each contiguous run of 'X' = one problem's column range ---
var withIdx = (0 to (maxWidth - 1)) map ((c) -> { c: c, x: (mask[c] == "X") })
var starts  = (withIdx filter ((o) -> o.x and ((o.c == 0) or (mask[o.c - 1] == " ")))) map $.c
var ends    = (withIdx filter ((o) -> o.x and ((o.c == maxWidth - 1) or (mask[o.c + 1] == " ")))) map $.c
var segments = (starts zip ends) map { startIdx: $[0], endIdx: $[1] }

// --- build each problem: pull the vertical numbers + the operator ---
fun sliceTrim(row, seg) = trim(row[seg.startIdx to seg.endIdx])
var problems = segments map ((seg) -> {
    nums: (paddedNumberRows map ((r) -> sliceTrim(r, seg))) filter (!isEmpty($)) map ($ as Number),
    op:   trim(paddedOpRow[seg.startIdx to seg.endIdx])
})

// --- solve each problem and sum the answers ---
fun solve(p) = if (p.op == "*") (p.nums reduce ($$ * $)) else (p.nums reduce ($$ + $))
var answers = problems map solve($)
---
{
    // problems:   problems,
    // answers:    answers,
    grandTotal: sum(answers as Array<Number>)
}
