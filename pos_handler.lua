return {
    get_pos_by_gps = function ()
        local pos = {}
        pos[1], pos[2], pos[3] = gps.locate()

        if #pos == 0 then
            local og_slot = turtle.getSelectedSlot()
            local item
            local saved_i
            for i = 1, 16 do
                turtle.select(i)
                item = turtle.getItemDetail()

                if item ~= nil then
                    if item.name == "computercraft:wireless_modem_advanced" then
                        turtle.equipLeft()
                        pos[1], pos[2], pos[3] = gps.locate()

                        turtle.equipLeft()
                        turtle.select(og_slot)

                        return pos
                    elseif item.name == "computercraft:wireless_modem_normal" then
                        saved_i = i
                    end
                end
            end

            if item ~= nil and saved_i ~= nil then
                turtle.select(saved_i)
                turtle.equipLeft()

                pos[1], pos[2], pos[3] = gps.locate()

                turtle.equipLeft()
            else
                print("no wireless connection found, cant get pos, defaulting to 0, 0, 0")
                pos = {0, 0, 0}
            end
            
            turtle.select(og_slot)
        end

        return pos
    end,

    get_pos_by_server = function (ws)
        ws.send(textutils.serialiseJSON({
            type = "request",
            request = "last_position"
        }))

        local success, result = pcall(ws.receive)

        if not success then
            print("couldnt ")
        end
    end
}