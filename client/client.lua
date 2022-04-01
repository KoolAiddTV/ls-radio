local PlayerData = {}
local radioMenu   = false

function enableRadio(enable)
    SetNuiFocus(true, true)
    radioMenu = enable
    SendNUIMessage({
        type = "enableui",
        enable = enable
    })
end

RegisterNUICallback('volup', function(data, cb)
    local volume = exports["pma-voice"]:getRadioVolume() * 100
    local newvol = volume + 10

    if volume < 90 then
        exports["pma-voice"]:setRadioVolume(newvol)
        exports['mythic_notify']:SendAlert('inform', 'Radio increased to ' .. newvol)
    end
    cb('ok')
end)

RegisterNUICallback('voldown', function(data, cb)
    local volume = exports["pma-voice"]:getRadioVolume() * 100
    local newvol = volume- 10

    if volume > 10 then
        exports["pma-voice"]:setRadioVolume(newvol)
        exports['mythic_notify']:SendAlert('inform', 'Radio decreased to ' .. newvol)
    end
    cb('ok')
end)

RegisterNUICallback('joinRadio', function(data, cb)
    local _source = source
    local PlayerData = ESX.GetPlayerData(_source)

    if tonumber(data.channel) then
        if tonumber(data.channel) <= Config.RestrictedChannels then
            if(PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' then
                exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
                exports["pma-voice"]:setRadioChannel(tonumber(data.channel))
                exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. ' MHz </b>')
            elseif not (PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'fire') then
                exports['mythic_notify']:SendAlert('error', Config.messages['restricted_channel_error'])
            end
        end
        if tonumber(data.channel) > Config.RestrictedChannels then
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
            exports["pma-voice"]:setRadioChannel(tonumber(data.channel))
            exports['mythic_notify']:SendAlert('inform', Config.messages['joined_to_radio'] .. data.channel .. ' MHz </b>')
        end
    else
        exports['mythic_notify']:SendAlert('error', Config.messages['you_on_radio'] .. data.channel .. ' MHz </b>')
    end
    cb('ok')
end)

RegisterNUICallback('leaveRadio', function(data, cb)
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    exports['mythic_notify']:SendAlert('inform', Config.messages['you_leave'])
    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    enableRadio(false)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('ls-radio:use')
AddEventHandler('ls-radio:use', function()
    enableRadio(true)
end)

RegisterNetEvent('ls-radio:onRadioDrop')
AddEventHandler('ls-radio:onRadioDrop', function(source)
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    exports['mythic_notify']:SendAlert('inform', Config.messages['you_leave'])
end)

Citizen.CreateThread(function()
    while true do
        if radioMenu then
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown
            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)
