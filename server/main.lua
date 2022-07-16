local QBCore = exports['qb-core']:GetCoreObject()

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate:upper()
    end
end

RegisterNetEvent('qb-vehiclecatalogue:server:buyvehicle', function(vehicle, color)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    local cid = pData.PlayerData.citizenid
    local cash = pData.PlayerData.money['cash']
    local bank = pData.PlayerData.money['bank']
    local vehiclePrice = QBCore.Shared.Vehicles[vehicle]['price']
    local plate = GeneratePlate()
    if cash > tonumber(vehiclePrice) then
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            'pillboxgarage',
            0
        })
        TriggerClientEvent('QBCore:Notify', src,  "You have bought a "..QBCore.Shared.Vehicles[vehicle]['name'], "success")
        TriggerClientEvent('qb-vehiclecatalogue:client:buyvehicle', src, vehicle, plate, color)
        pData.Functions.RemoveMoney('cash', vehiclePrice, 'vehicle-bought-from-catalogue')
    elseif bank > tonumber(vehiclePrice) then
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            pData.PlayerData.license,
            cid,
            vehicle,
            GetHashKey(vehicle),
            '{}',
            plate,
            'pillboxgarage',
            0
        })
        TriggerClientEvent('QBCore:Notify', src,  "You have bought a "..QBCore.Shared.Vehicles[vehicle]['name'], "success")
        TriggerClientEvent('qb-vehiclecatalogue:client:buyvehicle', src, vehicle, plate, color)
        pData.Functions.RemoveMoney('bank', vehiclePrice, 'vehicle-bought-from-catalogue')
    else
        TriggerClientEvent('QBCore:Notify', src,  "You dont have enough money for the "..QBCore.Shared.Vehicles[vehicle]['name'], "error")
        TriggerClientEvent("qb-vehiclecatalogue:closenui", src)
    end
end)