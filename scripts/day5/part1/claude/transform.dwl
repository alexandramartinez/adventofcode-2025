%dw 2.0
output application/json

var parts = payload splitBy "\n\n"

var ranges =
    (parts[0] splitBy "\n")
        filter (! isEmpty(trim($)))
        map ((line) -> (line splitBy "-") map ($ as Number))

var ids =
    (parts[1] splitBy "\n")
        filter (! isEmpty(trim($)))
        map ($ as Number)

fun isFresh(id: Number): Boolean =
    !isEmpty(ranges filter ((r) -> id >= r[0] and id <= r[1]))

---
{
    fresh: sizeOf(ids filter isFresh($))
}
