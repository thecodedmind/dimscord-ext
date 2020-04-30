import dimscord, asyncdispatch, os, ext, json

let cl = newDiscordClient(getEnv("BOT_TOKEN"))
var extm = newExtensionManager(cl,".")
extm.defaultCommands()

cl.events.on_ready = proc (s: Shard, r: Ready) = # Add Event Handler for on_ready.
    echo "Connected to Discord as " & $r.user

cl.events.message_create = proc (s: Shard, m: Message) = #  Add Event Handler for message_create.
    if m.author.bot: return
    extm.processCommands(m)

waitFor cl.startSession()
