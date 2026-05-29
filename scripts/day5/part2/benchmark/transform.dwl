%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
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
}

fun curietech() = do {
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
        totalFresh: sum(merged map ($.to - $.from + 1))
    }
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day5-part2": {
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
