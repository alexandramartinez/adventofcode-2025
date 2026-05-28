%dw 2.0
output application/json

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
