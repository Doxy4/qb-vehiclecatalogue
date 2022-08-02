QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}

local testDriveVeh, inTestDrive = 0, false
local testDriveZone = nil

local tablet = 0
local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local tabletAnim = "base"
local tabletProp = `prop_cs_tablet`
local tabletBone = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot = vector3(10.0, 160.0, 0.0)

Citizen.CreateThread(function()
    VehShop = AddBlipForCoord(Config.Shops["Blip"])
    SetBlipSprite (VehShop, 523)
    SetBlipDisplay(VehShop, 4)
    SetBlipScale(VehShop, 0.9)
    SetBlipAsShortRange(VehShop, false)
    SetBlipColour(VehShop, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Vehicle Shop")
    EndTextCommandSetBlipName(VehShop)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

local function drawTxt(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

RegisterNUICallback('buycar', function(data, cb)
    cb(true)
    TriggerServerEvent("qb-vehiclecatalogue:server:buyvehicle", data.carName, data.color)
end)

RegisterNUICallback('testcar', function(data, cb)
    cb(true)
    TriggerEvent("qb-vehiclecatalogue:client:testvehicle", data.carName)
end)

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

  Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k, v in pairs(Config.PedLocation) do
			local pos = GetEntityCoords(PlayerPedId())	
			local dist = #(pos - vector3(Config.PedLocation["coords"]))
			
			if dist < 60 and not pedspawned then
				TriggerEvent('qb-vehiclecatalogue:client:spawnped', v.coords)
				pedspawned = true
			end
			if dist >= 60 then
				pedspawned = false
                DeletePed(entity)
			end
		end
	end
end)
  
  
RegisterNetEvent("qb-vehiclecatalogue:client:spawnped", function()
    local model = `a_m_y_business_02`
  
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(0)
    end
  
    pedspawned = true
    entity = CreatePed(5, model, Config.PedLocation["coords"].x, Config.PedLocation["coords"].y, Config.PedLocation["coords"].z - 1, Config.PedLocation["coords"].w, false, false)
    FreezeEntityPosition(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)
    SetPedArmour(entity, 1000000)
    SetEntityHealth(entity, 1000000)
    loadAnimDict("amb@world_human_cop_idles@male@idle_b") 
    TaskPlayAnim(entity, "amb@world_human_cop_idles@male@idle_b", "idle_e", 8.0, 1.0, -1, 17, 0, 0, 0, 0)
    exports['qb-target']:AddTargetEntity(entity, { -- The specified entity number
      options = {
        {
          type = "client",
          event = "ui:client:open",
          icon = 'fas fa-square-minus',
          label = 'Open Catalogue',
          canInteract = function(entity, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
            if IsPedAPlayer(entity) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
            return true
          end,
        }
      },
      distance = 1.5,
    })
  end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(150)
    PlayerData = QBCore.Functions.GetPlayerData()
    callSign = PlayerData.metadata.callsign
end)

local function startTestDriveTimer(testDriveTime, prevCoords)
    local gameTimer = GetGameTimer()
    CreateThread(function()
        while inTestDrive do
            if GetGameTimer() < gameTimer + tonumber(1000 * testDriveTime) then
                local secondsLeft = GetGameTimer() - gameTimer
                if secondsLeft >= tonumber(1000 * testDriveTime) - 20 then
                    QBCore.Functions.DeleteVehicle(testDriveVeh)
                    testDriveVeh = 0
                    inTestDrive = false
                    SetEntityCoords(PlayerPedId(), prevCoords)
                    QBCore.Functions.Notify("You have completed the testdrive", "success")
                end
                drawTxt("Testdrive timer " .. math.ceil(testDriveTime - secondsLeft / 1000), 4, 0.5, 0.93, 0.50, 255, 255, 255, 180)
            end
            Wait(0)
        end
    end)
end

local returnTestDrive = {
    {
        header = 'Return vehicle',
        txt = "Return the test drive vehicle",
        icon = "fas fa-arrow-right-to-bracket",
        params = {
            event = 'qb-vehiclecatalogue:client:TestDriveReturn'
        }
    },
    {
        header = 'Close Menu',
        txt = "Close testdrive menu",
        icon = "fas fa-left-long",
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }
}

local function createTestDriveReturn()
    testDriveZone = BoxZone:Create(
        Config.Shops["ReturnLocation"],
        8.0,
        7.0,
        {
            name = "box_zone_qb-vehiclecatalogue_testdrive_return_",
        })

    testDriveZone:onPlayerInOut(function(isPointInside)
        if isPointInside and IsPedInAnyVehicle(PlayerPedId()) then
            SetVehicleForwardSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 0)
            exports['qb-menu']:openMenu(returnTestDrive)
        else
            exports['qb-menu']:closeMenu()
        end
    end)
end

local function doAnimation()
    if not isOpen then return end
    -- Animation
    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do Citizen.Wait(100) end
    -- Model
    RequestModel(tabletProp)
    while not HasModelLoaded(tabletProp) do Citizen.Wait(100) end

    local plyPed = PlayerPedId()
    local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(plyPed, tabletBone)

    AttachEntityToEntity(tabletObj, plyPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(tabletProp)

    CreateThread(function()
        while isOpen do
            Wait(0)
            if not IsEntityPlayingAnim(plyPed, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(plyPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end


        for k, v in pairs(GetGamePool('CObject')) do
            if IsEntityAttachedToEntity(PlayerPedId(), v) then
                SetEntityAsMissionEntity(v, true, true)
                DeleteObject(v)
                DeleteEntity(v)
                ClearPedSecondaryTask(plyPed)
            end
        end
    end)
end

local function EnableGUI(enable)
    SetNuiFocus(enable, enable)
    SendNUIMessage({ type = "show", enable = enable, job = PlayerData.job.name })
    isOpen = enable
    doAnimation()
end

local function RefreshGUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "show", enable = false, job = PlayerData.job.name })
    isOpen = false
end

RegisterNUICallback('escape', function(data, cb)
    EnableGUI(false)
    cb(true)
end)

RegisterNetEvent('ui:client:open', function()
    EnableGUI(true)
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    local zone = tostring(GetNameOfZone(x, y, z))
    local area = GetLabelText(zone)
    local playerStreetsLocation = area

    if not zone then zone = "UNKNOWN" end;

    if intersectStreetName ~= nil and intersectStreetName ~= "" then playerStreetsLocation = currentStreetName .. ", " .. intersectStreetName .. ", " .. area
    elseif currentStreetName ~= nil and currentStreetName ~= "" then playerStreetsLocation = currentStreetName .. ", " .. area
    else playerStreetsLocation = area end

    SendNUIMessage({ type = "data", name = "Welcome, " ..PlayerData.job.grade.name..' '..PlayerData.charinfo.lastname:sub(1,1):upper()..PlayerData.charinfo.lastname:sub(2), location = playerStreetsLocation, fullname = PlayerData.charinfo.firstname..' '..PlayerData.charinfo.lastname })
end)

RegisterNetEvent('qb-vehiclecatalogue:closenui', function()
    EnableGUI(false)
end)

RegisterNetEvent('qb-vehiclecatalogue:client:buyvehicle', function(vehicle, plate, color)
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleColours(veh, color, color)
        SetVehicleExtraColours(veh, color, 0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleNumberPlateText(veh, plate)
        SetEntityHeading(veh, Config.Shops["Vehicle"].w)
        SetVehicleDirtLevel(veh, 0.1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        TriggerServerEvent("qb-vehicletuning:server:SaveVehicleProps", QBCore.Functions.GetVehicleProperties(veh))
        TriggerEvent("qb-vehiclecatalogue:closenui")
    end, vehicle, Config.Shops["Vehicle"], false)
end)

RegisterNetEvent('qb-vehiclecatalogue:client:testvehicle', function(vehicle)
    if not inTestDrive then
        inTestDrive = true
        local prevCoords = GetEntityCoords(PlayerPedId())
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetVehicleDirtLevel(veh, 0.1)
        SetVehicleNumberPlateText(veh, 'TSTDRIVE')
        SetEntityAsMissionEntity(veh, true, true)
        SetEntityHeading(veh, Config.Shops["Vehicle"].w)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        TriggerServerEvent('qb-vehicletuning:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
        testDriveVeh = veh
        QBCore.Functions.Notify("You have 30 seconds", "success")
        TriggerEvent("qb-vehiclecatalogue:closenui")
    end, vehicle, Config.Shops["TestDriveSpawn"], false)
    createTestDriveReturn()
    startTestDriveTimer(Config.Shops["TestDriveTimeLimit"] * 60, prevCoords)
    else
        QBCore.Functions.Notify("You are already in a testdrive", "error")
    end
end)

RegisterNetEvent('qb-vehiclecatalogue:client:TestDriveReturn', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if veh == testDriveVeh then
        testDriveVeh = 0
        inTestDrive = false
        QBCore.Functions.DeleteVehicle(veh)
        exports['qb-menu']:closeMenu()
        testDriveZone:destroy()
    else
        QBCore.Functions.Notify("This is not your test drive vehicle", 'error')
    end
end)
