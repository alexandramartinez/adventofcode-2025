%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() =
    do {
        var rotations = (payload as String) splitBy "\n"
        var result = rotations reduce ((rotation, acc: {pos: Number, zeros: Number} = {pos: 50, zeros: 0}) ->
            do {
                var dir = rotation[0]
                var dist = rotation[1 to -1] as Number
                var raw = if (dir == "L") (acc.pos - dist) else (acc.pos + dist)
                var newPos = ((raw mod 100) + 100) mod 100
                var firstHit = if (dir == "L") (if (acc.pos == 0) 100 else acc.pos)
                               else (if (acc.pos == 0) 100 else (100 - acc.pos))
                var diff = dist - firstHit
                var zeroCount = if (firstHit <= dist) ((diff - (diff mod 100)) / 100 + 1) else 0
                ---
                {
                    pos: newPos,
                    zeros: acc.zeros + zeroCount
                }
            }
        )
        ---
        result.zeros
    }

fun curietech() =
    do {
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
    }

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day1-part2": {
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
