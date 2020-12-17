import "../ext", dimscord, asyncdispatch, strformat
import euwren

var wren = newWren()

proc loadWren*(e:var Extensions) =
    e.registerCommand("wren", proc(ext: Extensions, ctx:Context) {.async.} =
                                  wren.run(ctx.content)
    )
