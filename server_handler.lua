local host = read("host: ")

if host == "" then
    host = "ws://192.168.1.188:8765"
end



print("Connecting...")
local ws, err = http.websocket(host)

if not ws then
    print("Failed to connect: ".. tostring(err))
    return
end

--[[ here the handshake happens.
this is the structure of a handshake:
{
    "type": "hello",  (always that, it indicates this is a handshake)
    "capabilities": {}  (an object with the structure of "cap":["usecase1", "usecase2"] where the usecases are other types, eg "request", "ping", or more to come)
}
]]

ws.send(textutils.serialiseJSON({
    type = "hello",
    capabilities = {
        scan={"request"}
    }
}))



local msg = ws.receive()
local server_hello = textutils.unserialiseJSON(msg)

if server_hello.type ~= "hello" then
    print("Unexpected first message from server")
    return
end

print("Connected")

local pos = {}
pos[1], pos[2], pos[3] = gps.locate()

if #pos == 0 then
    print("oh no")
end


local geoscaner = peripheral.wrap("left")

while true do
    local scan = {}
    for i, v in ipairs(geoscaner.scan(4)) do
        scan[i] = {
            x = v.x,
            y = v.y,
            z = v.z,
            name = v.name,
        }
    end

    ws.send(textutils.serialiseJSON({
        type="request",
        surroundings=scan
    }))

    local response = ws.receive()

    if response then
        if response ~= "" then
            local cmd = textutils.unserialiseJSON(response)
            print("Got: "..cmd.action)
        end
    else
        print("Got nothing")
    end

    os.sleep(3)
end