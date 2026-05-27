%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() =
    do {
        var rotations = (payload as String) splitBy "\n"
        var result = rotations reduce ((rotation, acc = {pos: 50, zeros: 0}) ->
            do {
                var dir = rotation[0]
                var dist = rotation[1 to -1] as Number
                var raw = if (dir == "L") (acc.pos - dist) else (acc.pos + dist)
                var newPos = ((raw mod 100) + 100) mod 100
                ---
                {
                    pos: newPos,
                    zeros: acc.zeros + (if (newPos == 0) 1 else 0)
                }
            }
        )
        ---
        result.zeros
    }

fun curietech() =
    do {
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
    }

var claudeResult   = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day1-part1": {
        claude: {
            result:  claudeResult.result,
            timeMs:  claudeResult.end - claudeResult.start
        },
        curietech: {
            result:  curietechResult.result,
            timeMs:  curietechResult.end - curietechResult.start
        }
    }
}
