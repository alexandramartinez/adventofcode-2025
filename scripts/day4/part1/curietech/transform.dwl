%dw 2.0
output application/json
var raw = payload  // your puzzle input as a string
var grid = (raw splitBy "\n") map ($ splitBy "")
var rows = sizeOf(grid)
var cols = sizeOf(grid[0])
var offsets = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
fun cellAt(r, c) = if (r < 0 or r >= rows or c < 0 or c >= cols) "." else grid[r][c]
fun countN(r, c) = sizeOf(offsets filter (cellAt($[0] + r, $[1] + c) == "@"))
---
{
  accessible: sum(
    flatten(
      (0 to rows - 1) map ((r) ->
        (0 to cols - 1) map ((c) ->
          if (grid[r][c] == "@" and countN(r, c) < 4) 1 else 0
        )
      )
    )
  )
}
