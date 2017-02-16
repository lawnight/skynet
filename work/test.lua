package.cpath = "luaclib/?.so"

local socket = require "clientsocket"


if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end








while true do
		local cmdline =socket.readstdin()
        if cmdline then
		print (cmdline)
        end
		--print("===>",send_request("cmdline",1))
		--print("<===",recv_response(readpackage()))
end
	


--print("disconnect")
--socket.close(fd)


