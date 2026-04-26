local server_handler = require("server_handler")
local pos_handler = require("pos_handler")

io.write("host: ")
local host = io.read()

if host == "" then
    host = "ws://192.168.1.188:8765"
end

local server_hello, ws = server_handler.try_connect(host, {scan={"tick"}, position={"tick"}, time={"tick"}, day={"tick"}})

if ws == nil then return end


local geoscaner = peripheral.wrap("left")
local modem = peripheral.wrap("right")


while true do
    local scan = {}
    for i, v in ipairs(geoscaner.scan(1)) do
        if not (v.x==0 and v.y==0 and v.z==0) then
            scan[i] = {
                x = v.x,
                y = v.y,
                z = v.z,
                name = v.name,
            }
        end
    end



    server_handler.send_msg({
        type="tick",
        position=pos_handler.get_pos_by_gps(),
        scan=scan,
        time=textutils.formatTime(os.time(), true),
        day=os.day()
    }, ws, server_handler, host)



    local success, result = pcall(ws.receive)

    if not success then
        print("connection with server lost:")
        print(result)
        return
    end

    if not result then
        print("got nothing")
        return
    end

    local unserialised = textutils.unserialiseJSON(result)

    if not unserialised.action then
        return
    end

    modem.transmit(1, 1, unserialised.thought)

    if string.find(unserialised.action, "forward") then
        turtle.forward()
    elseif string.find(unserialised.action, "back") then
        turtle.back()
    elseif string.find(unserialised.action, "left") then
        turtle.turnLeft()
    elseif string.find(unserialised.action, "right") then
        turtle.turnRight()
    end

    os.sleep(3)
end