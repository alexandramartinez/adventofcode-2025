%dw 2.0
import time from dw::util::Timer
import pow from dw::core::Numbers
output application/json

fun claude() =
    do {
        fun pow10(n) = 10 pow n

        fun periodLengths(d) =
            (1 to (d - 1)) filter ((n) -> (d mod n) == 0)

        fun multiplier(n, k) =
            sum((0 to (k - 1)) map ((i) -> pow10(n * i)))

        fun invalidsForNK(lo, hi, n, k) =
            do {
                var m      = multiplier(n, k)
                var minX   = pow10(n - 1) as Number
                var maxX   = (pow10(n) - 1) as Number
                var xStart = max([ceil(lo / m), minX]) as Number
                var xEnd   = min([floor(hi / m), maxX]) as Number
                ---
                if (xStart > xEnd) []
                else (xStart to xEnd) map ((x) -> x * m)
            }

        fun invalidInRange(lo, hi) =
            do {
                var hiDigits = sizeOf((hi as String)) as Number
                ---
                (flatten((2 to hiDigits) map ((d) ->
                    flatten(periodLengths(d) map ((n) ->
                        invalidsForNK(lo, hi, n, d / n)
                    ))
                ))) distinctBy ((id) -> id)
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
        var allInvalid = (flatten(ranges map ((r) -> invalidInRange(r.lo, r.hi)))) distinctBy ((id) -> id)
        ---
        (if (isEmpty(allInvalid)) 0 else sum(allInvalid)) as String
    }

fun curietech() =
    do {
        fun maxF(x: Number, y: Number) = if (x > y) x else y
        fun minF(x: Number, y: Number) = if (x < y) x else y

        fun repMult(d: Number, k: Number): Number =
            ((10 pow (d * k)) - 1) / ((10 pow d) - 1)

        fun invalidInRange(a: Number, b: Number): Array<Number> = do {
            var maxLen = sizeOf(b as String)
            ---
            flatten((1 to maxLen) map ((d) ->
                flatten((2 to maxLen) filter (($ * d) <= maxLen) map ((k) -> do {
                    var R = repMult(d, k)
                    var pMin = maxF(ceil(a / R), 10 pow (d - 1))
                    var pMax = minF(floor(b / R), (10 pow d) - 1)
                    ---
                    if (pMin <= pMax) (pMin to pMax) map ($ * R) else []
                }))
            ))
        }

        var allInvalids = flatten(
            ((payload replace /\n/ with "") splitBy ",") map ((r) -> do {
                var parts = r splitBy "-"
                ---
                invalidInRange(parts[0] as Number, parts[1] as Number)
            })
        ) distinctBy $
        ---
        {
            count: sizeOf(allInvalids),
            total: sum(allInvalids)
        }
    }

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day2-part2": {
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
