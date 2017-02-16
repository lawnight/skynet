local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
	skynet.error("Server start")
	skynet.newservice("debug_console",8000)
	--skynet.newservice("debug_console",8000)
	
	--like this
	local loginserver = skynet.newservice("login/login_server")
	local server = skynet.newservice("server/game_server", loginserver)

	skynet.call(server, "lua", "open" , {
		port = 9000,
		maxclient = 64,
		servername = "sample",
	})

	skynet.exit()
end)