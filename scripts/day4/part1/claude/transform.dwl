%dw 2.0
output application/json
// payload is the puzzle input as a String (one row per line)

var grid = (payload splitBy "\n") filter (! isEmpty($)) map ($ splitBy "")
var rows = sizeOf(grid)
var cols = if (rows > 0) sizeOf(grid[0]) else 0

fun cellAt(r: Number, c: Number): String =
  if (r < 0 or c < 0 or r >= rows or c >= cols) "."
  else (grid[r][c] default ".")

fun neighborCount(r: Number, c: Number): Number =
  sum([-1, 0, 1] flatMap ((dr) ->
    [-1, 0, 1] map ((dc) ->
      if (dr == 0 and dc == 0) 0
      else if (cellAt(r + dr, c + dc) == "@") 1
      else 0
    )
  ))

var accessible = ((0 to (rows - 1)) as Array) flatMap ((r) ->
  ((0 to (cols - 1)) as Array) map ((c) ->
    if (cellAt(r, c) == "@" and neighborCount(r, c) < 4) 1 else 0
  )
)
---
{
  count: sum(accessible)
}
