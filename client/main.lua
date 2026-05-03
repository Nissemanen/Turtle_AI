local server_handler = require("server_handler")
local pos_handler = require("pos_handler")

io.write("host: ")
local host = io.read()

if host == "" then
    host = "ws://192.168.1.188:8765"
end

local server_hello, ws = server_handler.try_connect(host, {scan={"tick"}, position={"tick"}, time={"tick"}, day={"tick"}, facing={"tick"}})

if ws == nil then return end


local geoscaner = peripheral.wrap("left")
local modem = peripheral.wrap("right")
local facing = {0, 0}
local pos = pos_handler.get_pos_by_gps()


while true do
    print(textutils.serialiseJSON(facing))

    server_handler.send_msg({
        type="tick",
        position=pos,
        scan=pos_handler.get_surroundings(geoscaner, facing, 1),
        time=textutils.formatTime(os.time(), true),
        day=os.day(),
        facing=facing
    }, ws, server_handler, host)



    local success, result = pcall(ws.receive)

    -- bro i hate this, why doesnt lua have a god damn continue word,
    -- and why can't goto skip over creating variables?
    -- isn't that like one of the biggest reasons why to use it? when else would it be usefull

    if success then
        if  result then
            local unserialised = textutils.unserialiseJSON(result)

            if unserialised.action then
                modem.transmit(1, 1, unserialised.thought)

                if string.find(unserialised.action, "forward") then
                    turtle.forward()
                    pos, facing = pos_handler:calculate_pos(pos, facing, 1, 0)

                elseif string.find(unserialised.action, "back") then
                    turtle.back()
                    pos, facing = pos_handler:calculate_pos(pos, facing, -1, 0)

                elseif string.find(unserialised.action, "left") then
                    turtle.turnLeft()
                    pos, facing = pos_handler:calculate_pos(pos, facing, 0, -1)

                elseif string.find(unserialised.action, "right") then
                    turtle.turnRight()
                    pos, facing = pos_handler:calculate_pos(pos, facing, 0, 1)
                end
            end
        else
            print("got nothing")
        end
    else
        print("connection with server lost:")
        print(result)
    end

    os.sleep(3)
end