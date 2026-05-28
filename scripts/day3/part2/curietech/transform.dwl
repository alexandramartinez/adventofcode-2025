%dw 2.0
output application/json
// payload is the puzzle input as a String (one bank per line)

fun popWhile(stack: Array<Number>, d: Number, removed: Number, maxRemove: Number): Object =
  if (sizeOf(stack) > 0 and (stack[-1] default 0) < d and removed < maxRemove)
    popWhile(stack[0 to -2] default [], d, removed + 1, maxRemove)
  else
    { stack: stack, removed: removed }

fun pickMaxK(line: String, k: Number): String = do {
  var digits   = (line splitBy "") map ($ as Number)
  var n        = sizeOf(digits)
  var toRemove = n - k
  var finalAcc = digits reduce ((d, acc = { stack: [] as Array<Number>, removed: 0 }) ->
    do {
      var popped = popWhile(acc.stack, d, acc.removed, toRemove)
      ---
      { stack: (popped.stack << d), removed: popped.removed }
    }
  )
  // If we didn't use all removals, the leftover excess is at the tail — trim it.
  ---
  ((finalAcc.stack as Array)[0 to (k - 1)]) joinBy ""
}

var jolts = (payload splitBy "\n") map pickMaxK($, 12)
---
{
  banks: jolts,
  total: sum(jolts map ($ as Number))
}
