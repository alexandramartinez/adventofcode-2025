%dw 2.0
input payload text/plain
output text/plain
var lines = (payload splitBy "\n") map (trim($)) filter ($ != "")
fun step(acc, line) =
    do {
        var inst = (line splitBy "\t")[-1]
        var dir = inst[0 to 0]
        var dist = (inst[1 to -1]) as Number
        var pos = acc.pos as Number
        var firstK = if (dir == "R") (if (pos == 0) 100 else (100 - pos)) else (if (pos == 0) 100 else pos)
        var addZeros = if (firstK <= dist) (floor((dist - firstK) / 100) + 1) else 0
        var newPos = if (dir == "R") (pos + dist) mod 100 else (((pos - dist) mod 100) + 100) mod 100
        ---
        {pos: newPos, zeros: acc.zeros + addZeros}
    }
var result = lines reduce ((line, acc = {pos: 50, zeros: 0}) -> step(acc, line))
---
result.zeros as String
