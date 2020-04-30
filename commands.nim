import ext, dimscord

proc loadCommands*(e:var Extensions) =
    discard e.registerCommand("say-ath", proc(ctx:Context) =
                                                let c = ctx.getChannel("athena")
                                                c.send(ctx, ctx.argsRaw)
    )

    discard e.registerCommand("reply", proc(ctx:Context) =
                                                ctx.reply("You got it boss..")
    )
