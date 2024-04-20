--on top of client.lua
---@field onnearEnter fun(self: CZone)?
---@field onnearExit fun(self: CZone)?





---@type table<number, CZone>
local insideZones = {}
---@type table<number, CZone>
local enteringZones = {}
---@type table<number, CZone>
local exitingZones = {}
local enteringSize = 0
local exitingSize = 0
local nearZones = {}
---@type table<number, CZone>
local enteringnearZones = {}
---@type table<number, CZone>
local exitingnearZones = {}
local enteringnearSize = 0
local exitingnearSize = 0
local tick
local glm_polygon_contains = glm.polygon.contains

local function removeZone(self)
    Zones[self.id] = nil
    insideZones[self.id] = nil
    enteringZones[self.id] = nil
    exitingZones[self.id] = nil
    enteringnearZones[self.id] = nil
    exitingnearZones[self.id] = nil
end

CreateThread(function()
    while true do
        local coords = GetEntityCoords(cache.ped)
        cache.coords = coords

        for _, zone in pairs(Zones) do
            zone.distance = #(zone.coords - coords)
            local radius, contains = zone.radius, nil

            if radius then
                contains = zone.distance < radius
            else
                contains = glm_polygon_contains(zone.polygon, coords, zone.thickness / 4)
            end

            if contains then
                if not zone.insideZone then
                    zone.insideZone = true

                    if zone.onEnter then
                        enteringSize += 1
                        enteringZones[enteringSize] = zone
                    end

                    if zone.inside or zone.debug then
                        insideZones[zone.id] = zone
                    end
                end
            else
                if zone.insideZone then
                    zone.insideZone = false
                    insideZones[zone.id] = nil

                    if zone.onExit then
                        exitingSize += 1
                        exitingZones[exitingSize] = zone
                    end
                end

                if zone.debug then
                    insideZones[zone.id] = zone
                end
            end

            if zone.benear ~= nil and zone.distance < zone.benear  then
                if not zone.nearZone then
                    zone.nearZone = true

                    if zone.onEnter then
                        enteringnearSize += 1
                        enteringnearZones[enteringnearSize] = zone
                    end

                    if zone.inside or zone.debug then
                        nearZones[zone.id] = zone
                    end
                end
            elseif zone.benear  ~= nil  then
                if zone.nearZone then
                    zone.nearZone = false
                    nearZones[zone.id] = nil

                    if zone.onExit then
                        exitingnearSize += 1
                        exitingnearZones[exitingnearSize] = zone
                    end
                end

                if zone.debug then
                    nearZones[zone.id] = zone
                end
            end
        end

        if exitingSize > 0 then
            table.sort(exitingZones, function(a, b)
                return a.distance > b.distance
            end)

            for i = 1, exitingSize do
                exitingZones[i]:onExit()
            end

            exitingSize = 0
            table.wipe(exitingZones)
        end

        if enteringSize > 0 then
            table.sort(enteringZones, function(a, b)
                return a.distance < b.distance
            end)

            for i = 1, enteringSize do
                enteringZones[i]:onEnter()
            end

            enteringSize = 0
            table.wipe(enteringZones)
        end

        if exitingnearSize > 0 then
            table.sort(exitingnearZones, function(a, b)
                return a.distance > b.distance
            end)

            for i = 1, exitingnearSize do                
                    exitingnearZones[i]:onnearExit()
            end

            exitingnearSize = 0
            table.wipe(exitingnearZones)
        end

        if enteringnearSize > 0 then
            table.sort(enteringnearZones, function(a, b)
                return a.distance < b.distance
            end)

            for i = 1, enteringnearSize do
                    enteringnearZones[i]:onnearEnter()
            end

            enteringnearSize = 0
            table.wipe(enteringnearZones)
        end


        if not tick then
            if next(insideZones) then
                tick = SetInterval(function()
                    for _, zone in pairs(insideZones) do
                        if zone.debug then
                            zone:debug()

                            if zone.inside and zone.insideZone then
                                zone:inside()
                            end
                        else
                            zone:inside()
                        end
                    end
                end)
            end
        elseif not next(insideZones) then
            tick = ClearInterval(tick)
        end

        Wait(300)
    end
end)
