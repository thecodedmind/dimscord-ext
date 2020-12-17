import dimscord, asyncdispatch, os, ext, json, "nim.ext/commands", "nim.ext/api"

let cl = newDiscordClient(getEnv("BOT_TOKEN"))
var extm = newExtensionManager(cl, ".")
extm.defaultCommands()
loadCommands(extm)
extm.loadAPICommands()
#extm.loadWren()
#loadExtensions("nim.ext")
cl.events.on_ready = proc (s: Shard, r: Ready) {.async.} = # Add Event Handler for on_ready.
        echo "Connected to Discord as " & $r.user

cl.events.message_create = proc (s: Shard, m: Message) {.async.} = #  Add Event Handler for message_create.
        if m.author.bot: return
        try:
                await extm.processCommands(m, s)
        except Exception as e:
                echo "Caught exception: " & e.msg

waitFor cl.startSession()
