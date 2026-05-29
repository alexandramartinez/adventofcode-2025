%dw 2.0
output application/json

var parts = payload splitBy "\n\n"

var ranges =
    (parts[0] splitBy "\n")
        filter (! isEmpty(trim($)))
        map ((line) -> (line splitBy "-") map ($ as Number))

var sorted = ranges orderBy $[0]

var merged = (sorted[1 to -1] default []) reduce ((r, acc = [sorted[0]]) -> do {
    var last = acc[-1]
    ---
    if (r[0] <= last[1] + 1)
        (acc[0 to -2] default []) << [last[0], max([last[1], r[1]])]
    else
        acc << r
})

---
{
    fresh: sum(merged map ($[1] - $[0] + 1))
}
