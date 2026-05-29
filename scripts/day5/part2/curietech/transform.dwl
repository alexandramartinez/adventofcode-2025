%dw 2.0
output application/json
// payload = the full puzzle input as text/plain

var rangeLines = trim((payload splitBy "\n\n")[0]) splitBy "\n"

var ranges = rangeLines map (line) -> {
    from: (line splitBy "-")[0] as Number,
    to:   (line splitBy "-")[1] as Number
}

var sorted = ranges orderBy $.from
var merged = sorted reduce (r, acc=[]) ->
    if (acc == [] or r.from > ((acc[-1].to default 0) + 1))
        acc << r
    else
        (acc[0 to -2] default []) << { from: acc[-1].from, to: max([acc[-1].to, r.to]) }
---
{
    // merged:     merged,
    totalFresh: sum(merged map ($.to - $.from + 1))
}
