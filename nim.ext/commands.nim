import "../ext", dimscord, asyncdispatch, strformat

proc loadCommands*(e:var Extensions) =
    e.registerCommand("say-ath", proc(ext: Extensions, ctx:Context) {.async.} =
                                                let c = ctx.getChannel("athena")
                                                await c.send(ctx, ctx.argsRaw)
    )

    e.registerCommand("inviteme", proc(ext: Extensions, ctx:Context) {.async.} =
             await ctx.reply(fmt"https://discordapp.com/oauth2/authorize?client_id=699655328991674448&scope=bot")
                                             
    )
    
    e.registerCommand("channel", proc(ext: Extensions, ctx:Context) {.async.} =
                                                await ctx.send(ctx.channel.mention())
    )
