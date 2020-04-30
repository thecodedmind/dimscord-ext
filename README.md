# Dimscord Extensions
A set of utilities for convenience around the [https://github.com/krisppurg/dimscord/](Dimscord) library.\n
Currently work-in-progress, basic commands can be added as seen in the example, but not every idea or concept\n
is fleshed out yet.

```nim
import dimscord, asyncdispatch, os, ext, json

let cl = newDiscordClient(getEnv("BOT_TOKEN"))
var extm = newExtensionManager(cl,".") # Kai: Create the Extension Manager object with whatever prefix
# For example, `.` as the prefix makes the commands trigger if the message starts with `.`

extm.defaultCommands() # Loads the default command set

# Creating new commands is easy
# ctx is a new object added in the extensions, which holds all relevant info for a command
# It also adds convenient methods for sending messages, instead of `waitFor cl.api.sendMessage(m.channel_id, "ping?")`,
# you can just use `ctx.send("ping?"` to send to the channel the command ran in
# other wrapper methods like Reply to automatically mention the user in a reply coming soon.

# in Ctx, they have two fields for the commands arguments
# if the user ran `.echo this is a test` 
# ctx.args is ["this", "is", "a", "test"] sequence
# whereas ctx.argsRaw is "this is a test" string
extm.registerCommand("say", proc(ctx:Context) =
ctx.send(ctx.argsRaw) 
)
	
extm.registerCommand("say-admin", proc(ctx:Context) =
# ctx also adds get* methods, to quickly grab an object from cache
# works based on either ID, or string name
# included is `getChannel`, `getGuild`, `getMember`, `getUser`
let c = ctx.getChannel("admin-room")
# Passing a channel object to paramater one of send, sends the message to that channel instead of the
# executing channel
ctx.send(c, ctx.argsRaw) 
)	
		
cl.events.on_ready = proc (s: Shard, r: Ready) = # Add Event Handler for on_ready.
    echo "Connected to Discord as " & $r.user

cl.events.message_create = proc (s: Shard, m: Message) = #  Add Event Handler for message_create.
    if m.author.bot: return
    extm.processCommands(m) # sends the message to the command handler
	
waitFor cl.startSession()

```

