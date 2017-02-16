local msgserver = require "snax.msgserver"
local crypt = require "crypt"
local skynet = require "skynet"

local loginservice = tonumber(...)

local server = {}
local users = {}
local username_map = {}
local internal_id = 0


-- call by agent
function server.logout_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[uid] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",uid, subid)
	end
end

-- call by login server
function server.kick_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
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

-- login server调用
local internal_id = 0
function server.login_handler(uid, secret)
	-- you should return unique subid
	internal_id = internal_id+1
    local id = internal_id
    local username = msgserver.username(uid, id, servername)
   
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
	msgserver.login(username, secret)
	return id
end


-- msgserver call (when gate open),通知login server，有多少gameserver
function server.register_handler(name)
	servername = name
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
end

msgserver.start(server)

