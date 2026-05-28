%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
    var K = 12

    fun indexOfMax(arr: Array<Number>): Number =
        ((0 to sizeOf(arr) - 1) as Array<Number>) reduce ((i, acc = 0) ->
            if (arr[i] > arr[acc]) i else acc
        )

    fun pickK(digits: Array<Number>, remaining: Number, start: Number): Array<Number> =
        if (remaining == 0) []
        else do {
            var endIdx = sizeOf(digits) - remaining
            var window = digits[start to endIdx]
            var pos = start + indexOfMax(window)
            ---
            [digits[pos]] ++ pickK(digits, remaining - 1, pos + 1)
        }

    fun digitsToNumber(digits: Array<Number>): Number =
        digits reduce ((d, acc = 0) -> acc * 10 + d)

    fun maxJoltage(line: String): Number = do {
        var digits = (line splitBy "") map ((c) -> (c default "0") as Number)
        ---
        digitsToNumber(pickK(digits, K, 0))
    }

    var text = payload as String
    var lines = (text splitBy "\n") map ((l) -> (l default "") replace /\r/ with "") filter ($ != "")
    var perBank = lines map ((l) -> maxJoltage(l))
    ---
    {
        perBank: perBank,
        total: sum(perBank)
    }
}

fun curietech() = do {
    fun popWhile(stack: Array<Number>, d: Number, removed: Number, maxRemove: Number): Object =
        if (sizeOf(stack) > 0 and (stack[-1] default 0) < d and removed < maxRemove)
            popWhile(stack[0 to -2] default [], d, removed + 1, maxRemove)
        else
            { stack: stack, removed: removed }

    fun pickMaxK(line: String, k: Number): String = do {
        var digits   = (line splitBy "") map ($ as Number)
        var n        = sizeOf(digits)
        var toRemove = n - k
        var finalAcc = digits reduce ((d, acc = { stack: [] as Array<Number>, removed: 0 }) ->
            do {
                var popped = popWhile(acc.stack, d, acc.removed, toRemove)
                ---
                { stack: (popped.stack << d), removed: popped.removed }
            }
        )
        ---
        ((finalAcc.stack as Array)[0 to (k - 1)]) joinBy ""
    }

    var jolts = (payload splitBy "\n") map pickMaxK($, 12)
    ---
    {
        banks: jolts,
        total: sum(jolts map ($ as Number))
    }
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day3-part2": {
        claude: {
            result:  claudeResult.result.total,
            timeMs:  claudeResult.end - claudeResult.start
        },
        curietech: {
            result:  curietechResult.result.total,
            timeMs:  curietechResult.end - curietechResult.start
        }
    }
}
