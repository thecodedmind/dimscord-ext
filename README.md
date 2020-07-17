# Dimscord Extensions
A set of utilities for convenience around the [Dimscord](https://github.com/krisppurg/dimscord/) library.

Currently work-in-progress, basic commands can be added as seen in the example, but not every idea or concept
is fleshed out yet.

I'm no expert at Nim still, but I have fun writing things, and I really wanted to make a discord
bot in the language. But Nim has struggled with having good libraries for a while, with most
not being functional. But then Dimscord came around, and it worked! So then I began my quest,
to write a discord bot, following the same design philosophy I've used for other languages,
creating a modular and extendible wrapper around an existing library that maybe doesn't
include all the functionality I'd want, and create it myself.
So, here we are. Mostly keeping this up as a backup for myself, but if it's useful to 
anyone else getting starting in Dimscordian things, go wild. It's still in early stages,
and things are subject to change, especially since the base library I'm working around
is also currently in development, some things I do might become redundant or break when the
library updates, but thats life. 
~Kaiser

## TODO
 [ ] Help system<br>
 [ ] Inline Permission checks for commands<br>
 [ ] Background processes<br>
 [ ] Other stuff (undecided)<br>
 
## Utilities

ctx.getGuild(name_or_id)<br>
ctx.getChannel(^)<br>
ctx.getUser(^)<br>
ctx.getMember(^)<br>
ctx.send(message)<br>
channel.send(ctx, ^)<br>
ctx.reply(^) - Does not currently work, unsure why<br>
member.mention() -> returns a string representation of a member, see above.<br>
channel.mention() -> ^ for a channel<br>
ext.registerCommand(name, proc(ctx))<br>

```nim
import dimscord, asyncdispatch, os, ext, json

let cl = newDiscordClient(getEnv("BOT_TOKEN"))
var extm = newExtensionManager(cl,".") # TCM: Create the Extension Manager object with whatever prefix
# For example, `.` as the prefix makes the commands trigger if the message starts with `.`

extm.defaultCommands() # Loads the default command set

# TCM; Creating new commands is easy
# ctx is a new object added in the extensions, which holds all relevant info for a command
# It also adds convenient methods for sending messages, 
# instead of `waitFor cl.api.sendMessage(m.channel_id, "ping?")`,
# you can just use `ctx.send("ping?")` to send to the channel the command ran in
# or ctx.reply("you got it") to include a mention to the member automatically

# in Ctx, they have two fields for the commands arguments
# if the user ran `.echo this is a test` 
# ctx.args is ["this", "is", "a", "test"] sequence
# whereas ctx.argsRaw is "this is a test" string
discard extm.registerCommand("say", proc(ctx:Context) {.async.} =
await ctx.send(ctx.argsRaw) 
)
	
extm.registerCommand("say-admin", proc(ctx:Context) {.async.} =
# TCM: ctx also adds get* methods, to quickly grab an object from cache
# works based on either ID, or string name
# included is `getChannel`, `getGuild`, `getMember`, `getUser`
let c = ctx.getChannel("admin-room")
# Passing a channel object to paramater one of send, sends the message to that channel instead of the
# executing channel. c.send(ctx, text) also works. OPTIONS!
await ctx.send(c, ctx.argsRaw) 
)	
		
cl.events.on_ready = proc (s: Shard, r: Ready) = # Add Event Handler for on_ready.
    echo "Connected to Discord as " & $r.user

cl.events.message_create = proc (s: Shard, m: Message) = #  Add Event Handler for message_create.
    if m.author.bot: return
    extm.processCommands(m) # TCM: sends the message to the command handler
	
waitFor cl.startSession()

```

