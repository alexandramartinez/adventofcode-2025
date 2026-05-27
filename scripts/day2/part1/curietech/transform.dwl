%dw 2.0
output application/json
import pow from dw::core::Numbers

var data = "...your input..."

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
  (data splitBy ",") map ((r) -> do {
    var parts = r splitBy "-"
    ---
    invalidInRange(parts[0] as Number, parts[1] as Number)
  })
)
---
{ total: sum(allInvalids), count: sizeOf(allInvalids) }