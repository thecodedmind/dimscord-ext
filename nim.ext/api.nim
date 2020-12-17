import "../ext", dimscord, asyncdispatch, strformat, httpclient, json, options, strutils, "../nimoji"

type
    TResultServer = object
        gamename*, gametype*, mapname*, maptitle*, hostname*, description*, ip*, country*, added*, updated*: string
        numplayers*, maxplayers*, diff*, hostport*, id*: int
        
    TServer = object
        
    TResult = object
        game*: string
        servers*: seq[TResultServer]
        num_players*, num_servers*: int

proc get333nServer(s:TResultServer): Future[TServer] {.async.} =
    let url = fmt"http://333networks.com/json/" & s.gamename & "/" & s.hostname & ":{s.hostport}"
    echo "todo - pings api for resultservers gamename and host"
    
proc get333nServer(game, host:string): Future[TServer] {.async.} =
    let url = "http://333networks.com/json/" & game & "/" & host
    echo "todo"
    
proc get333nList(game:string, sort = "numplayers", order = "d", limit = "10"): Future[TResult] {.async.} =
    result.game = game
    let url = "http://333networks.com/json/" & game & "?s=" & sort & "&o=" & order & "&r=" & limit
    var client = newAsyncHttpClient()
    try:
        let content = await client.getContent(url)
        let a = parseJson(content)
        result.num_players = a[1]["players"].getInt
        result.num_servers = a[1]["total"].getInt
        for server in a[0]:
            result.servers.add server.to(TResultServer)
    except:
        echo "Error in access."
        
proc loadAPICommands*(e:var Extensions) =
        e.registerCommand("333n", proc(ext: Extensions, ctx:Context) {.async.} =
                                      var t = waitFor get333nList(ctx.argsRaw)
                                      var em = newEmbed()
                                      
                                      for s in t.servers:
                                          let flag = emojify(":flag-"&s.country.toLower()&":")
                                          em.addField(fmt"{flag}{s.hostname} ({s.numplayers}/{s.maxplayers})",
                                                      fmt"**Host**: {s.ip}:{s.hostport} | **Gametype**: {s.gametype} | **Map**: {s.mapname} ({s.maptitle})")

                                      em.setDescription(fmt"Players: {t.num_players}, Servers: {t.num_servers}")    
                                      await ctx.send(em)#.build)
                                      #[]discard await ctx.client.api.sendMessage(
                                          ctx.channel.id,
                                          embed = some Embed(
                                              title: some "Hello there!", 
                                              description: some "This is description",
                                              color: some 0x7789ec,
                                              fields: some @[
                                                  EmbedField(name: t.servers[0].hostname, value: t.servers[0].ip)
                                              ]
                                          )
                                      )]#
                                      
        )
