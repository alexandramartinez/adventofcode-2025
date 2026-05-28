%dw 2.0
import time from dw::util::Timer
output application/json

fun claude() = do {
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
}

fun curietech() = do {
    var grid = (payload splitBy "\n") map ($ splitBy "")
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
}

var claudeResult    = time(() -> claude())
var curietechResult = time(() -> curietech())
---
{
    "day4-part1": {
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
