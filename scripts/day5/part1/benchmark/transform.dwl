%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
    var parts = payload splitBy "\n\n"

    var ranges =
        (parts[0] splitBy "\n")
            filter (! isEmpty(trim($)))
            map ((line) -> (line splitBy "-") map ($ as Number))

    var ids =
        (parts[1] splitBy "\n")
            filter (! isEmpty(trim($)))
            map ($ as Number)

    fun isFresh(id: Number): Boolean =
        !isEmpty(ranges filter ((r) -> id >= r[0] and id <= r[1]))
    ---
    {
        fresh: sizeOf(ids filter isFresh($))
    }
}

fun curietech() = do {
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
        freshCount: sizeOf(ids filter (id) -> isFresh(id))
    }
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day5-part1": {
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
