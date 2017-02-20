local gateserver = require "snax.gateserver"
local crypt = require "crypt"
local skynet = require "skynet"
local netpack = require "netpack"


local driver = require "socketdriver"


local server = {}
local users = {}
local username_map = {}
local internal_id = 0

local connection = {}

local handler = {}


function handler.command(cmd, source, ...)	
end


function handler.open(source, conf)
	--watchdog = conf.watchdog or source	
end

--玩家连接上来
function handler.connect(fd, addr)
	--must open socket new agent
	gateserver.openclient(fd)

end


--msg
function handler.message(fd, msg, sz)
	local string = netpack.tostring(msg,sz)
	print("fd:",fd,string)
	--respond

	local package = string.pack(">s2", string)
	driver.send(fd, package)

end

function handler.disconnect(fd)
end

function handler.error(fd, msg)
end

function handler.warning(fd, size)
end



gateserver.start(handler)

