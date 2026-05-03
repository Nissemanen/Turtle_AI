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
    end,

    calculate_pos= function (self, old, facing, movement, rotation)
        local new_pos
        if facing[1] == 0 and facing[2]==0 then
            new_pos = self.get_pos_by_gps()
            facing = {(new_pos[1] - old[1])*movement, (new_pos[3] - old[3])*movement}
        end

        if rotation ~= 0 then
            facing = {facing[2] * -rotation, facing[1] * rotation}
        end

        if new_pos ~= nil then
            return new_pos, facing
        end

        return {old[1] + facing[1]*movement, old[2], old[3] + facing[2]*movement}, facing
    end,

    get_surroundings= function (geoscaner, facing, radius)
        local scan = {}

        print(facing)

        if facing[1] == 0 and facing[2] == 0 then
            facing = {1,0}
        end

        for i, v in ipairs(geoscaner.scan(radius)) do
            if not (v.x==0 and v.y==0 and v.z==0) then
                scan[i] = {
                    x = v.x * facing[1] - v.z * facing[2],
                    y = v.y,
                    z = v.x * facing[1] + v.z * facing[2],
                    name = v.name
                }
            end
        end

        return scan
    end
}