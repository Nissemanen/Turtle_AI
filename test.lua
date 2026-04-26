local server_handler = require("server_handler")

local host = "ws://192.168.1.188:8765"

local serv_hello, ws = server_handler.try_connect(host)


local geo = peripheral.wrap("left")

local scan = {}
for i, v in ipairs(geo.scan(1)) do
    scan[i] = {
        x=v.x,
        y=v.y,
        z=v.z,
        name=v.name
    }
end


server_handler.send_msg({type="tick", scan=scan}, ws)