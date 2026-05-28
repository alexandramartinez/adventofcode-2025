%dw 2.0
output application/json

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
