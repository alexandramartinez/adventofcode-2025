%dw 2.0
output application/json

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
