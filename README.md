# zones_ox_lib_isnear
adds onnearExit() and onnearEnter() functions to zones of ox_lib eg. for drawmarkers

All love and appreciation goes to overextended, they are making the best inventory for FiveM out there!

here an example I use in illenium-appearance (these are just the functions/threads I changed/added):





    local near = false
    local function onnearEnter(data)
        local index = lookupZoneIndexFromID(Zones.Store, data.id)
        local store = Config.Stores[index]
    
        local jobName = (store.job and client.job.name) or (store.gang and client.gang.name)
        if jobName == (store.job or store.gang) then
            nearZone = {
                coords = store.coords,
                index = index
            }    
        end
    end
    
    local function onnearExit(data)
        local index = lookupZoneIndexFromID(Zones.Store, data.id)
        local store = Config.Stores[index]
    
        local jobName = (store.job and client.job.name) or (store.gang and client.gang.name)
        if jobName == (store.job or store.gang) then
            nearZone = nil
        end
    end
    
    local function SetupZone(store, onEnter, onExit)
        if Config.RCoreTattoosCompatibility and store.type == "tattoo" then
            return {}
        end
    
        if Config.UseRadialMenu or store.usePoly then
            return lib.zones.poly({
                points = store.points,
                debug = Config.Debug,
                onEnter = onEnter,
                onExit = onExit,
                onnearEnter = onnearEnter,
                onnearExit = onnearExit,
                benear = 15,    --define distance to trigger functions onnearEnter and onnearExit
            })
        end
    
        return lib.zones.box({
            coords = store.coords,
            size = store.size,
            rotation = store.rotation,
            debug = Config.Debug,
            onEnter = onEnter,
            onExit = onExit,
            onnearEnter = onnearEnter,
            onnearExit = onnearExit,
            benear = 15, --define distance to trigger functions onnearEnter and onnearExit
        })
    end

    
    local function ZonesLoop()
        Wait(1000)
        while true do
            local sleep = 1000
            if currentZone then
                sleep = 5
                if IsControlJustReleased(0, 38) then
                    if currentZone.name == "clothingRoom" then
                        local clothingRoom = Config.ClothingRooms[currentZone.index]
                        local outfits = GetPlayerJobOutfits(clothingRoom.job)
                        TriggerEvent("illenium-appearance:client:openJobOutfitsMenu", outfits)
                    elseif currentZone.name == "playerOutfitRoom" then
                        local outfitRoom = Config.PlayerOutfitRooms[currentZone.index]
                        OpenOutfitRoom(outfitRoom)
                    elseif currentZone.name == "clothing" then
                        TriggerEvent("illenium-appearance:client:openClothingShopMenu")
                    elseif currentZone.name == "barber" then
                        OpenBarberShop()
                    elseif currentZone.name == "tattoo" then
                        OpenTattooShop()
                    elseif currentZone.name == "surgeon" then
                        OpenSurgeonShop()
                    end
                end
            end
            if nearZone then
                DrawMarker(27,nearZone.coords.x,nearZone.coords.y,nearZone.coords.z-1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 4.0, 4.0, 4.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                sleep = 0
            end
            Wait(sleep)
        end
    end
