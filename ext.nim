import dimscord, strutils, tables, asyncdispatch, json, strformat

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
        
    Command* = object
        name*: string
        execute*: proc(ctx: Context)
        autorun*: proc(client: DiscordClient)
        
    Extensions* = object
        commands*: Table[string, Command]
        prefix*:string
        client*: DiscordClient

proc newContext*(m:Message, e:Extensions):Context =
    result.cache = e.client.cache
    result.message = m
    result.member = m.member
    result.author = m.author
    result.guild = e.client.cache.guilds[m.guild_id]
    result.channel = e.client.cache.guildChannels[m.channel_id]
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
        if member.nick == m or m in member.nick or member.user.username == m or m in member.user.username:
            result = member

proc mention*(m: Member):string =
    if m == nil:
        return "UNDEFINED"
    if m.user == nil:
        return m.nick:
    return fmt"<@{m.user.id}>" #DOES NOT WORK
    
proc mention*(m: GuildChannel):string =
    return fmt"<#{m.id}>"
     
proc newExtensionManager*(client:DiscordClient, prefix:string = "."):Extensions =
    result.commands = initTable[string, Command]()
    result.prefix = prefix
    result.client = client
    
proc registerCommand*(ext:var Extensions, name:string, fn:proc):Command =
    result.name = name
    result.execute = fn
    ext.commands[name] = result

proc processCommands*(ext: Extensions, message:Message) =
    echo message.author.username & ": " & message.content
    if message.content.startsWith(ext.prefix):
            var ctx = newContext(message, ext)
            if ext.commands.hasKey(ctx.commandName):
                let c = ext.commands[ctx.commandName]
                c.execute(ctx)

proc send*(ctx:Context, content:string) =
    discard waitFor ctx.client.api.sendMessage(ctx.channel.id, content)
    
proc send*(channel:GuildChannel, ctx:Context, content:string) =
    discard waitFor ctx.client.api.sendMessage(channel.id, content)

proc reply*(ctx:Context, content:string) =
    discard waitFor ctx.client.api.sendMessage(ctx.channel.id, fmt"{ctx.member.mention()}, {content}")
    
proc defaultCommands*(e: var Extensions) =
    discard e.registerCommand("echo", proc(ctx:Context) =
                                  ctx.send(ctx.argsRaw)
    )
