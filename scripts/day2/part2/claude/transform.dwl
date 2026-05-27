%dw 2.0
input payload text/plain
output text/plain

fun pow10(n) = 10 pow n

// Proper divisors of d (i.e. divisors < d), giving possible period lengths
fun periodLengths(d) =
    (1 to (d - 1)) filter ((n) -> (d mod n) == 0)

// Multiplier for period length n repeated k times: 1 + 10^n + 10^(2n) + ... + 10^((k-1)*n)
fun multiplier(n, k) =
    sum((0 to (k - 1)) map ((i) -> pow10(n * i)))

// All invalid IDs in [lo, hi] with given period length n and repeat count k
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

// All unique invalid IDs in [lo, hi] across all digit lengths and period lengths
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
