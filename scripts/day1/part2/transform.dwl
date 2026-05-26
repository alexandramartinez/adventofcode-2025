%dw 2.0
output application/json

var rotations = (payload as String) splitBy "\n"

var result = rotations reduce ((rotation, acc: {pos: Number, zeros: Number} = {pos: 50, zeros: 0}) ->
  do {
    var dir = rotation[0]
    var dist = rotation[1 to -1] as Number
    var raw = if (dir == "L") (acc.pos - dist) else (acc.pos + dist)
    var newPos = ((raw mod 100) + 100) mod 100
    // first step index at which dial hits 0; every 100 steps after that also hits 0
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
