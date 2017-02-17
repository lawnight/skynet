local gateserver = require "snax.gateserver"
local crypt = require "crypt"
local skynet = require "skynet"

local loginservice = tonumber(...)

local server = {}
local users = {}
local username_map = {}
local internal_id = 0

local connection = {}


-- call by agent
function server.logout_handler(uid, subid)
	local u = users[uid]
	if u then
		
		local username = server.username(uid, subid, servername)

		assert(u.username == username)
		gateserver.logout(u.username)
		users[uid] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",uid, subid)
	end
end

-- call by login server
function server.kick_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = server.username(uid, subid, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk")
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	local u = username_map[username]
	return skynet.tostring(skynet.rawcall(u.agent, "text", msg))
end



function server.username(uid,id,servername)
	return uid..id
end

-- gateserver call (when gate open),通知login server，有多少gameserver
function server.register_handler(name)
	servername = name
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
end


local handler = {}




function handler.message(fd, msg, sz)
	-- recv a package, forward it
	local c = connection[fd]
	local agent = c.agent
	if agent then
		skynet.redirect(agent, c.client, "client", 1, msg, sz)
	else
		skynet.send(watchdog, "lua", "socket", "data", fd, netpack.tostring(msg, sz))
	end
end



local function unforward(c)
	if c.agent then
		forwarding[c.agent] = nil
		c.agent = nil
		c.client = nil
	end
end

local function close_fd(fd)
	local c = connection[fd]
	if c then
		unforward(c)
		connection[fd] = nil
	end
end

function handler.disconnect(fd)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "close", fd)
end

function handler.error(fd, msg)
	close_fd(fd)
	skynet.send(watchdog, "lua", "socket", "error", fd, msg)
end

function handler.warning(fd, size)
	skynet.send(watchdog, "lua", "socket", "warning", fd, size)
end

local CMD = {}

function CMD.forward(source, fd, client, address)
	local c = assert(connection[fd])
	unforward(c)
	c.client = client or 0
	c.agent = address or source
	forwarding[c.agent] = c
	gateserver.openclient(fd)
end

function CMD.accept(source, fd)
	local c = assert(connection[fd])
	unforward(c)
	gateserver.openclient(fd)
end

function CMD.kick(source, fd)
	gateserver.closeclient(fd)
end


-- login server调用
local internal_id = 0
function CMD.login(uid, secret)
	print("ffffffffffffffffffffffff")
	-- you should return unique subid
	internal_id = internal_id+1
    local id = internal_id    
	
	local username = server.username(uid, id, servername)   
    local agent = skynet.newservice "player"
	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = id,
	}

    skynet.call(agent, "lua", "login", uid, id, secret)
	users[uid] = u
	username_map[username] = u
	
	--gateserver.login(username, secret)
	print("ffffffffffffffffffffffff")
	return id
end

function handler.command(cmd, source, ...)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

--注册服务器到login
function handler.open(source, conf)
	--watchdog = conf.watchdog or source
	print("regist server"..conf.servername)
	local servername = assert(conf.servername)
	return server.register_handler(servername)
end

--玩家连接上来
function handler.connect(fd, addr)
	local c = {
		fd = fd,
		ip = addr,
	}
	connection[fd] = c
	--skynet.send(watchdog, "lua", "socket", "open", fd, addr)
end

gateserver.start(handler)

