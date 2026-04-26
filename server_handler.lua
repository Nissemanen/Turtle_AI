return {
    ---Try connect to the server using special handshake
    ---@param host string
---@diagnostic disable-next-line: undefined-doc-name
    ---@return table, websocket|nil
    try_connect= function (host, capabilities)
        print("Connecting to "..host)

        local ws, err = http.websocket(host)

        if not ws then
            print("Failed to connect: "..err)
            return {type="no connection", err=err}, nil
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
            capabilities = capabilities
        }))

        local msg = ws.receive()
        local server_hello = textutils.unserialiseJSON(msg)

        if server_hello.type ~= "hello" then
            print("Unexpected first message from server")
            return server_hello, ws
        end

        print("Connected")
        return server_hello, ws
    end,

    send_msg= function (data, ws, self, host)
        ::continue::

        local success, err = pcall(ws.send, textutils.serialiseJSON(data))

        if not success then
            print("couldnt send message to server:")
            print(err)

            if host then
                ::retry::
                local server_hello
                server_hello, ws = self.try_connect(host)

                if server_hello.type == "no connection" then
                    io.write("couldn't reconnect, try again? [y/N] ")
                    local ans = io.read()

                    if ans:lower() == "y" then
                        goto retry
                    end

                    os.exit()
                end

                goto continue
            end
        end
    end
}