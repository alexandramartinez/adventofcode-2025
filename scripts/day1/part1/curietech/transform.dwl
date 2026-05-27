%dw 2.0
input payload text/plain
output text/plain
var lines = (payload splitBy "\n") map (trim($)) filter ($ != "")
var result = lines reduce ((line, acc = {pos: 50, count: 0}) -> 
    do {
        var dir = line[0]
        var dist = (line[1 to -1]) as Number
        var newPos = if (dir == "L") (((acc.pos - dist) mod 100) + 100) mod 100
                     else (acc.pos + dist) mod 100
        ---
        {pos: newPos, count: acc.count + (if (newPos == 0) 1 else 0)}
    }
)
---
result.count