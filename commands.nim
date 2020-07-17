import ext, dimscord, asyncdispatch, strformat

proc loadCommands*(e:var Extensions) =
    e.registerCommand("say-ath", proc(ext: Extensions, ctx:Context) {.async.} =
                                                let c = ctx.getChannel("athena")
                                                await c.send(ctx, ctx.argsRaw)
    )

    e.registerCommand("reply", proc(ext: Extensions, ctx:Context) {.async.} =
                                                await ctx.reply(fmt"You got it boss..")
                                                await ctx.send(fmt"You got it {ctx.member.user.id}")
    )
    
    e.registerCommand("channel", proc(ext: Extensions, ctx:Context) {.async.} =
                                                await ctx.send(ctx.channel.mention())
    )
