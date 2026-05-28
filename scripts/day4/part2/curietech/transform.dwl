%dw 2.0
output application/json
var raw = payload  // your puzzle input as a string
var grid0 = (raw splitBy "\n") map ($ splitBy "")
var rows = sizeOf(grid0)
var cols = sizeOf(grid0[0])
var offsets = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]

fun cellAt(g, r, c) =
  if (r < 0 or r >= rows or c < 0 or c >= cols) "." else g[r][c]

fun countN(g, r, c) =
  sizeOf(offsets filter (cellAt(g, $[0] + r, $[1] + c) == "@"))

// One "pass": remove every @ that currently has < 4 @ neighbors, simultaneously.
fun step(g) =
  (0 to rows - 1) map ((r) ->
    (0 to cols - 1) map ((c) ->
      if (g[r][c] == "@" and countN(g, r, c) < 4) "." else g[r][c]
    )
  )

fun countAt(g) =
  sum(flatten(g map ($ map (if ($ == "@") 1 else 0))))

// Recurse until a pass removes nothing.
fun solve(g, removed) = do {
    var newG = step(g)
    var justRemoved = countAt(g) - countAt(newG)
    ---
    if (justRemoved == 0) removed
    else solve(newG, removed + justRemoved)
}
---
{
  totalRemoved: solve(grid0, 0)
}
