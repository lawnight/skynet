local gateserver = require "snax.gateserver"
local skynet = require "skynet"

local handler = {}

-- register handlers here
function handler.command(cmd, source, ...)
	
end

--注册服务器到login
function handler.open(source, conf)
	--watchdog = conf.watchdog or source
	
	
end

--玩家连接上来
function handler.connect(fd, addr)
	print("connectingggggggggggg")
	--skynet.send(watchdog, "lua", "socket", "open", fd, addr)
end


--msg
function handler.message(fd, msg, sz)
	-- recv a package, forward it	
	print("msgmsgmsgmsgmsgmsgmsgmsg")
end

function handler.disconnect(fd)
end

function handler.error(fd, msg)
end

function handler.warning(fd, size)
end

local SOCKET = {}


function SOCKET.open(fd, addr)
	skynet.error("New client from : " .. addr)
end


gateserver.start(handler)

