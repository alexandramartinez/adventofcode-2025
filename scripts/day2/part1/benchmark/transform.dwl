%dw 2.0
import time from dw::util::Timer
import pow from dw::core::Numbers
output application/json

fun claude() =
    do {
        fun pow10(n) = 10 pow n

        fun invalidsForHalfLen(lo, hi, halfLen) =
            do {
                var mult   = pow10(halfLen) + 1
                var minX   = pow10(halfLen - 1) as Number
                var maxX   = (pow10(halfLen) - 1) as Number
                var xStart = max([ceil(lo / mult), minX]) as Number
                var xEnd   = min([floor(hi / mult), maxX]) as Number
                ---
                if (xStart > xEnd) []
                else (xStart to xEnd) map ((x) -> x * mult)
            }

        fun invalidInRange(lo, hi) =
            do {
                var maxHalfLen = floor(sizeOf((hi as String)) / 2) as Number
                ---
                if (maxHalfLen < 1) []
                else flatten((1 to maxHalfLen) map ((halfLen) -> invalidsForHalfLen(lo, hi, halfLen)))
            }

        var ranges = ((payload replace /\n/ with "") splitBy ",")
            map trim($)
            filter ($ != "")
            map ((r) ->
                do {
                    var parts = r splitBy "-"
                    ---
                    {lo: parts[0] as Number, hi: parts[1] as Number}
                }
            )
        var allInvalid = flatten(ranges map ((r) -> invalidInRange(r.lo, r.hi)))
        ---
        (if (isEmpty(allInvalid)) 0 else sum(allInvalid)) as String
    }

fun curietech() =
    do {
        fun maxF(x: Number, y: Number) = if (x > y) x else y
        fun minF(x: Number, y: Number) = if (x < y) x else y

        fun invalidInRange(a: Number, b: Number): Array<Number> = do {
            var maxK = floor(sizeOf(b as String) / 2)
            ---
            flatten((1 to maxK) map ((k) -> do {
                var mult  = (10 pow k) + 1
                var pMin  = maxF(ceil(a / mult), 10 pow (k - 1))
                var pMax  = minF(floor(b / mult), (10 pow k) - 1)
                ---
                if (pMin <= pMax) (pMin to pMax) map ($ * mult) else []
            }))
        }

        var allInvalids = flatten(
            ((payload replace /\n/ with "") splitBy ",") map ((r) -> do {
                var parts = r splitBy "-"
                ---
                invalidInRange(parts[0] as Number, parts[1] as Number)
            })
        )
        ---
        { total: sum(allInvalids), count: sizeOf(allInvalids) }
    }

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day2-part1": {
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
