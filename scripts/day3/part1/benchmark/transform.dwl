%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
    fun maxJoltage(line: String): Number = do {
        var digits = (line splitBy "") map ((c) -> (c default "0") as Number)
        var n = sizeOf(digits)
        var pairs = flatten(
            (0 to n - 2) map ((i) ->
                ((i + 1) to n - 1) map ((j) ->
                    digits[i] * 10 + digits[j]
                )
            )
        )
        ---
        max(pairs) default 0
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
    var data = payload
    var banks = data splitBy "\n"

    fun maxJoltage(line) = do {
        var digits = (line splitBy "") map ($ as Number)
        var pairs = (0 to (sizeOf(digits) - 2)) flatMap ((i) ->
            ((i + 1) to (sizeOf(digits) - 1)) map ((j) ->
                digits[i] * 10 + digits[j]
            )
        )
        ---
        (max(pairs) default 0) as Number
    }

    var perBank = banks map ((b) -> maxJoltage(b))
    ---
    {
        perBank: perBank,
        total: sum(perBank)
    }
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day3-part1": {
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
