%dw 2.0
input payload text/plain
output text/plain

fun pow10(n) = 10 pow n

// For a given half-length n, an invalid ID = X * (10^n + 1) where X is an n-digit number.
// Find all such IDs in [lo, hi] by computing valid X range via division.
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
