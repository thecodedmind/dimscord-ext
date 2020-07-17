import dimscord, strutils, tables, asyncdispatch, json, strformat, options

type
    Context* = object
        message*: Message
        member*:Member
        author*:User
        guild*:Guild
        channel*:GuildChannel
        commandName*:string
        args*:seq[string]
        argsRaw*:string
        cache*:CacheTable
        client*:DiscordClient
        shard*:Shard
        
    Command* = object
        name*, brief*, help*, usage*: string
        execute*: proc(e: Extensions, ctx: Context) {.async.}
        autorun*: proc(client: DiscordClient) {.async.}
        
    Extensions* = object
        commands*: Table[string, Command]
        prefix*: string
        client*: DiscordClient

proc newContext*(m:Message, e:Extensions, s:Shard):Context =
    result.cache = s.cache
    result.message = m
    result.member = m.member.get
    result.author = m.author
    result.member.user = result.author
    result.shard = s
    if m.guild_id.get("") != "":
        result.guild = s.cache.guilds[m.guild_id.get]
    result.channel = s.cache.guildChannels[m.channel_id]
    let parts = m.content.split()
    result.commandName = parts[0].replace(e.prefix, "") 
    result.args = parts[1..(parts.len()-1)]
    result.argsRaw = result.args.join(" ")
    result.client = e.client
    
proc getGuild*(ctx:Context, guildName:string):Guild=
    if ctx.cache.guilds.hasKey(guildName):
        return ctx.cache.guilds[guildName]

    for guild in ctx.cache.guilds.values:
        if guild.name == guildName or guildName in guild.name:
            result = guild
            
proc getChannel*(ctx:Context, chanName:string):GuildChannel=
    if ctx.cache.guildChannels.hasKey(chanName):
        return ctx.cache.guildChannels[chanName]

    for channel in ctx.cache.guildChannels.values:
        if channel.name == chanName or chanName in channel.name:
            result = channel
            
proc getChannel*(guild:Guild, chanName:string):GuildChannel=
    if guild.channels.hasKey(chanName):
        return guild.channels[chanName]

    for channel in guild.channels.values:
        if channel.name == chanName or chanName in channel.name:
            result = channel
            
proc getMember*(guild:Guild, m:string):Member=
    if guild.members.hasKey(m):
        return guild.members[m]

    for member in guild.members.values:
        if member.nick.get("") == m or m in member.nick.get("") or member.user.username == m or m in member.user.username:
            result = member

proc mention*(m: User):string =
    return fmt"<@{m.id}>"
    
proc mention*(m: GuildChannel):string =
    return fmt"<#{m.id}>"
     
proc newExtensionManager*(client:DiscordClient, prefix:string = "."):Extensions =
    result.commands = initTable[string, Command]()
    result.prefix = prefix
    result.client = client
    
proc registerCommand*(ext:var Extensions, name:string, fn:proc) =
    var c = Command()
    c.name = name
    c.execute = fn
    ext.commands[name] = c
    
proc setBrief(ext: var Extensions, c, b:string) =
    ext.commands[c].brief = b

proc setHelp(ext: var Extensions, c, b:string) =
    ext.commands[c].help = b
    
proc setUsage(ext: var Extensions, c, b:string) =
    ext.commands[c].usage = b
        
proc processCommands*(ext: Extensions, message:Message, shard:Shard) {.async.} =
    echo message.author.username & ": " & message.content
    if message.content.startsWith(ext.prefix):
            var ctx = newContext(message, ext, shard)
            if ext.commands.hasKey(ctx.commandName):
                let c = ext.commands[ctx.commandName]
                await c.execute(ext, ctx)

proc send*(ctx:Context, content:string) {.async.} =
    discard await ctx.client.api.sendMessage(ctx.channel.id, content)
    
proc send*(channel:GuildChannel, ctx:Context, content:string) {.async.} =
    discard await ctx.client.api.sendMessage(channel.id, content)

proc reply*(ctx:Context, content:string) {.async.} =
    discard await ctx.client.api.sendMessage(ctx.channel.id, fmt"{ctx.author.mention()}, {content}")
    
proc defaultCommands*(e: var Extensions) =
    e.registerCommand("echo", proc(ext: Extensions, ctx:Context) {.async.} =
            await ctx.send(ctx.argsRaw)
    )
    e.setBrief("echo", "..cho... cho... ho... o")
    e.setHelp("echo", "Repeats what you enter.")
    e.setUsage("echo", "[text]")
    
    e.registerCommand("help", proc(ext: Extensions, ctx:Context) {.async.} =
            var outp = "```\n"
            if ctx.argsRaw == "":
                for k, v in ext.commands.pairs:
                    outp.add v.name&" ".repeat(15-v.name.len)&v.brief
                    outp.add "\n"
                outp.add "```"
                await ctx.reply(outp)
            else:
                if ext.commands.hasKey(ctx.argsRaw):
                    await ctx.reply("```\n"&ext.prefix&ctx.argsRaw&" "&ext.commands[ctx.argsRaw].usage&"\n"&ext.commands[ctx.argsRaw].brief&"\n"&ext.commands[ctx.argsRaw].help&"```")
                else:
                    await ctx.reply("Command not found.")
                    
                    
    )
