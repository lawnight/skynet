local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"

local server = {
	host = "127.0.0.1",
	port = 8001,
	multilogin = false,	-- disallow multilogin
	name = "login_master",
	instance = 1,
}

local server_list = {}
local user_online={}


--vertify token,and get server,user,password param
function server.auth_handler(token)
	--print("receive token:",token)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	assert(password == "password", "Invalid password")
	print(server)
	return server, user
end


--找出对应的server ，准备登陆
function server.login_handler(server, uid, secret)	
	local gameserver = server_list[server]
	--让游戏服务器准备，返回subid给客服端，secret。
	print("secret:",secret)
	local subid = tostring(skynet.call(gameserver, "lua", "login", uid, secret))
	--user_online[uid] = { address = gameserver, subid = subid , server = server}	
	print("login handler done")
	return subid
end


local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
end

--处理lua类消息
function server.command_handler(command, ...)
	print("receive command:",command)
	local f = assert(CMD[command])
	return f(...)
end
--print "login server start!"
login(server)