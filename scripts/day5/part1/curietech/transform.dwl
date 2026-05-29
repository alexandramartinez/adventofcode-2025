%dw 2.0
output application/json
// payload = the full puzzle input as text/plain

// Split the two sections on the blank line
var sections   = payload splitBy "\n\n"
var rangeLines = trim(sections[0]) splitBy "\n"
var idLines    = trim(sections[1]) splitBy "\n"

var ranges = rangeLines map (line) -> {
    from: (line splitBy "-")[0] as Number,
    to:   (line splitBy "-")[1] as Number
}

fun isFresh(id) = sizeOf(ranges filter (r) -> id >= r.from and id <= r.to) > 0

var ids = idLines map ($ as Number)
---
{
    // freshIds:   ids filter (id) -> isFresh(id),
    freshCount: sizeOf(ids filter (id) -> isFresh(id))
}
