%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
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
}

fun curietech() = do {
    var grid0 = (payload splitBy "\n") map ($ splitBy "")
    var rows = sizeOf(grid0)
    var cols = sizeOf(grid0[0])
    var offsets = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]

    fun cellAt(g, r, c) =
        if (r < 0 or r >= rows or c < 0 or c >= cols) "." else g[r][c]

    fun countN(g, r, c) =
        sizeOf(offsets filter (cellAt(g, $[0] + r, $[1] + c) == "@"))

    fun step(g) =
        (0 to rows - 1) map ((r) ->
            (0 to cols - 1) map ((c) ->
                if (g[r][c] == "@" and countN(g, r, c) < 4) "." else g[r][c]
            )
        )

    fun countAt(g) =
        sum(flatten(g map ($ map (if ($ == "@") 1 else 0))))

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
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day4-part2": {
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
