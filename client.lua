ESX = exports["es_extended"]:getSharedObject()

local pedSpawned = false
local pedEntity = nil
local robbedPeds = {} -- Table pour stocker les entités déjà volées localement

-- Fonction pour ouvrir le menu UI
function OpenSellMenu()
    ESX.TriggerServerCallback('sk_pawnshop:getSellableItems', function(data)
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            items = data.items,
            reputation = data.reputation,
            locales = {
                ui_title = _U('ui_title'),
                ui_total_estimated = _U('ui_total_estimated'),
                ui_sell_all = _U('ui_sell_all'),
                ui_level = _U('ui_level'),
                ui_level_max = _U('ui_level_max'),
                ui_locked = _U('ui_locked'),
                ui_level_required = _U('ui_level_required'),
                ui_sell_btn = _U('ui_sell_btn')
            }
        })
    end)
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sell', function(data, cb)
    TriggerServerEvent('sk_pawnshop:sellItem', data.item, data.price, data.count)
    cb('ok')
end)

RegisterNUICallback('sellAll', function(data, cb)
    local items = data.items or {}
    for _, item in ipairs(items) do
        TriggerServerEvent('sk_pawnshop:sellItem', item.item, item.price, item.count)
        Wait(50) 
    end
    -- On ferme après tout vendre
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Fonction PNJ Recéleur
local function SpawnPed()
    if pedSpawned then return end

    local model = lib.requestModel(Config.PedModel)
    if not model then return end

    -- On tente de trouver le sol proprement
    local foundGround, zPos = GetGroundZFor_3dCoord(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, false)
    if foundGround then
        pedEntity = CreatePed(4, model, Config.PedCoords.x, Config.PedCoords.y, zPos, Config.PedCoords.w, false, true)
    else
        pedEntity = CreatePed(4, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z, Config.PedCoords.w, false, true)
    end
    
    -- Configuration "Poteau"
    SetEntityInvincible(pedEntity, true)
    FreezeEntityPosition(pedEntity, true)
    
    -- Bloquer toute réaction IA
    SetBlockingOfNonTemporaryEvents(pedEntity, true)
    SetPedFleeAttributes(pedEntity, 0, 0)
    SetPedCombatAttributes(pedEntity, 46, true)

    SetModelAsNoLongerNeeded(model)

    -- Ajout Target
    exports.ox_target:addLocalEntity(pedEntity, {
        {
            name = 'pawnshop_talk',
            icon = 'fas fa-sack-dollar',
            label = _U('pawnshop_talk'),
            onSelect = function()
                OpenSellMenu()
            end
        }
    })

    pedSpawned = true
end

local function DeletePed()
    if pedEntity and DoesEntityExist(pedEntity) then
        DeleteEntity(pedEntity)
    end
    pedSpawned = false
end

-- 🕵️ PICKPOCKET LOGIC
if Config.Pickpocket.Enabled then
    exports.ox_target:addGlobalPed({
        {
            name = 'pickpocket_ped',
            icon = 'fas fa-user-secret',
            label = _U('pickpocket_label'),
            canInteract = function(entity, distance, coords, name, bone)
                -- Pas le joueur lui-même
                if entity == PlayerPedId() then return false end
                -- Pas les joueurs (isPedAPlayer est natif FiveM recent ou via check)
                if IsPedAPlayer(entity) then return false end
                -- Pas les PNJ morts
                if IsEntityDead(entity) then return false end
                -- Pas les PNJ en voiture
                if IsPedInAnyVehicle(entity, true) then return false end
                
                -- Pas si déjà volé récemment
                if robbedPeds[entity] then return false end

                -- Pas le recéleur lui-même (optionnel mais logique)
                if entity == pedEntity then return false end

                return true
            end,
            onSelect = function(data)
                local entity = data.entity
                
                -- On fige le PNJ pendant la fouille pour pas qu'il parte
                FreezeEntityPosition(entity, true)

                -- Animation de vol (Le joueur fouille)
                if lib.progressBar({
                    duration = Config.Pickpocket.Duration,
                    label = _U('searching'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        combat = true, 
                    },
                    anim = {
                        dict = 'anim@gangops@facility@servers@bodysearch@', 
                        clip = 'player_search' 
                    },
                }) then
                    -- On libère le PNJ
                    FreezeEntityPosition(entity, false)

                    -- SKILL CHECK
                    -- Plus facile : 'easy' (lent) et touche 'e' uniquement
                    local success = lib.skillCheck({'easy', 'easy'}, {'e'}) 

                    if success then
                        -- SUCCES
                        robbedPeds[entity] = true
                        
                        TriggerServerEvent('sk_pickpocket:success')
                        
                        TaskReactAndFleePed(entity, PlayerPedId())
                        
                        SetTimeout(Config.Pickpocket.Cooldown, function()
                            robbedPeds[entity] = nil
                        end)
                    else
                        -- ECHEC
                        lib.notify({
                            title = _U('failed_title'),
                            description = _U('failed_desc'),
                            type = 'error'
                        })
                        
                        TaskReactAndFleePed(entity, PlayerPedId())

                        -- Alerte Police
                        if math.random(1, 100) <= Config.Pickpocket.AlertPoliceChance then
                            print("Police Alertée (Simulé)")
                        end
                    end
                else
                    -- Si annulé
                    FreezeEntityPosition(entity, false)
                    lib.notify({description = _U('canceled'), type = 'info'})
                end
            end
        }
    })
end

-- Blip (inchangé)
if Config.BlipName then
    local blip = AddBlipForCoord(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(blip)
end

-- Boucle Recéleur (inchangé)
Citizen.CreateThread(function()
    while true do
        local sleep = 1500
        local playerPed = cache.ped
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - vector3(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z))

        if dist < 50.0 then
            SpawnPed()
            if dist < 50.0 then sleep = 1000 end
        else
            if pedSpawned then
                DeletePed()
            end
        end

        Wait(sleep)
    end
end)
