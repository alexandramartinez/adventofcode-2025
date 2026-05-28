%dw 2.0
output application/json
// payload is the puzzle input as a String (one row per line)

var initialGrid = (payload splitBy "\n") filter (! isEmpty($)) map ($ splitBy "")
var rows = sizeOf(initialGrid)
var cols = if (rows > 0) sizeOf(initialGrid[0]) else 0

fun cellAt(g: Array<Array<String>>, r: Number, c: Number): String =
  if (r < 0 or c < 0 or r >= rows or c >= cols) "."
  else (g[r][c] default ".")

fun neighborCount(g: Array<Array<String>>, r: Number, c: Number): Number =
  sum(([-1, 0, 1] as Array) flatMap ((dr) ->
    ([-1, 0, 1] as Array) map ((dc) ->
      if (dr == 0 and dc == 0) 0
      else if (cellAt(g, r + dr, c + dc) == "@") 1
      else 0
    )
  ))

fun accessibleMask(g: Array<Array<String>>): Array<Array<Boolean>> =
  ((0 to (rows - 1)) as Array) map ((r) ->
    ((0 to (cols - 1)) as Array) map ((c) ->
      cellAt(g, r, c) == "@" and neighborCount(g, r, c) < 4
    )
  )

fun countTrue(mask: Array<Array<Boolean>>): Number =
  sum(mask map sum($ map (if ($) 1 else 0)))

fun applyMask(g: Array<Array<String>>, mask: Array<Array<Boolean>>): Array<Array<String>> =
  ((0 to (rows - 1)) as Array) map ((r) ->
    ((0 to (cols - 1)) as Array) map ((c) ->
      if (mask[r][c]) "." else cellAt(g, r, c)
    )
  )

fun removeAll(g: Array<Array<String>>, total: Number): Number = do {
  var mask = accessibleMask(g)
  var removed = countTrue(mask)
  ---
  if (removed == 0) total
  else removeAll(applyMask(g, mask), total + removed)
}
---
{
  count: removeAll(initialGrid, 0)
}
