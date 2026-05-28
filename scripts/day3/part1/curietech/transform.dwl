%dw 2.0
output application/json
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
