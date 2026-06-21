ESX = exports["es_extended"]:getSharedObject()

-- 💾 SAVING SYSTEM (MySQL Async)

local function GetPlayerXP(identifier, cb)
    MySQL.Async.fetchScalar('SELECT xp FROM sk_reputation WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(xp)
        cb(xp or 0)
    end)
end

local function AddPlayerXP(identifier, amount)
    GetPlayerXP(identifier, function(currentXp)
        local newXp = currentXp + amount
        MySQL.Async.execute('INSERT INTO sk_reputation (identifier, xp) VALUES (@identifier, @xp) ON DUPLICATE KEY UPDATE xp = @xp', {
            ['@identifier'] = identifier,
            ['@xp'] = newXp
        })
    end)
end

local function GetLevelFromXP(xp)
    local level = 1
    for lvl, reqXp in pairs(Config.Reputation.Levels) do
        if xp >= reqXp and lvl > level then
            level = lvl
        end
    end
    return level
end

-- Callback pour vérifier les items vendables + INFO REPUTATION
-- Callback pour vérifier les items vendables + INFO REPUTATION
ESX.RegisterServerCallback('sk_pawnshop:getSellableItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    GetPlayerXP(xPlayer.identifier, function(xp)
        local sellableItems = {}
        local level = GetLevelFromXP(xp)
        
        -- On parcourt la config pour voir ce que le joueur possède
        for _, configItem in ipairs(Config.ItemsToSell) do
            local count = exports.ox_inventory:GetItem(source, configItem.item, nil, true) -- true pour compter uniquement
            
            if count > 0 then
                local isLocked = level < (configItem.minLevel or 1)
    
                table.insert(sellableItems, {
                    label = _U(configItem.label),
                    item = configItem.item,
                    price = configItem.price,
                    count = count,
                    totalPrice = count * configItem.price,
                    minLevel = configItem.minLevel or 1,
                    locked = isLocked
                })
            end
        end
    
        cb({
            items = sellableItems,
            reputation = {
                xp = xp,
                level = level,
                label = _U(Config.Reputation.Labels[level]) or "Inconnu",
                nextLevelXp = Config.Reputation.Levels[level + 1] or "Max"
            }
        })
    end)
end)

-- Event de vente
RegisterNetEvent('sk_pawnshop:sellItem')
AddEventHandler('sk_pawnshop:sellItem', function(itemName, itemPrice, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    GetPlayerXP(xPlayer.identifier, function(xp)
        local level = GetLevelFromXP(xp)

        -- 1. Vérification de sécurité (Item existe dans la config ?)
        local isValidItem = false
        local validPrice = 0
        local minLevel = 1

        for _, v in pairs(Config.ItemsToSell) do
            if v.item == itemName then
                isValidItem = true
                validPrice = v.price
                minLevel = v.minLevel or 1
                break
            end
        end

        if not isValidItem then
            print(('[sk_pawnshop] TENTATIVE DE TRICHE : %s a essayé de vendre %s (non listé).'):format(GetPlayerName(src), itemName))
            return
        end

        -- 2. Vérification du niveau
        if level < minLevel then
            TriggerClientEvent('ox_lib:notify', src, {
                title = _U('too_inexperienced_title'),
                description = _U('too_inexperienced_desc'),
                type = 'error'
            })
            return
        end

        -- 3. On retire l'item via OX Inventory
        local success = exports.ox_inventory:RemoveItem(src, itemName, count)

        if success then
            local totalMoney = validPrice * count
            
            if Config.PaymentType == 'black_money' then
                xPlayer.addAccountMoney('black_money', totalMoney)
            elseif Config.PaymentType == 'bank' then
                xPlayer.addAccountMoney('bank', totalMoney)
            else
                xPlayer.addMoney(totalMoney)
            end

            -- Gain d'XP (On le fait après)
            local earnedXp = Config.Reputation.XpPerSale * count
            AddPlayerXP(xPlayer.identifier, earnedXp)
            
            -- Vérif Level Up (sommaire)
            local newLevel = GetLevelFromXP(xp + earnedXp)
            if newLevel > level then
                TriggerClientEvent('ox_lib:notify', src, {
                    title = _U('level_up_title'),
                    description = _U('level_up_desc', _U(Config.Reputation.Labels[newLevel])),
                    type = 'success',
                    icon = 'arrow-up'
                })
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = _U('sell_success_title'),
                    description = _U('sell_success_desc', count, totalMoney, earnedXp),
                    type = 'success'
                })
            end
            
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = _U('error_title'),
                description = _U('not_enough_items'),
                type = 'error'
            })
        end
    end)
end)

-- Event Pickpocket Réussi (Déjà existant, je le laisse tel quel ou je rajoute de l'XP aussi ?)
RegisterNetEvent('sk_pickpocket:success')
AddEventHandler('sk_pickpocket:success', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Algorithme de sélection pondérée
    
    -- Chance de rien trouver (Poches vides)
    if math.random(1, 100) > (Config.Pickpocket.FindChance or 100) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = _U('nothing_found_title'),
            description = _U('nothing_found_desc'),
            type = 'warning'
        })
        return
    end

    GetPlayerXP(xPlayer.identifier, function(xp)
        local level = GetLevelFromXP(xp)
        
        local validLoot = {}
        local totalWeight = 0

        -- Filtrage par niveau
        for _, item in pairs(Config.Pickpocket.Loot) do
            if not item.minLevel or level >= item.minLevel then
                table.insert(validLoot, item)
                totalWeight = totalWeight + item.chance
            end
        end

        local randomNum = math.random(1, totalWeight)
        local currentWeight = 0
        local selectedItem = nil

        for _, item in pairs(validLoot) do
            currentWeight = currentWeight + item.chance
            if randomNum <= currentWeight then
                selectedItem = item
                break
            end
        end

        if selectedItem then
            local qty = math.random(selectedItem.min, selectedItem.max)
            
            if selectedItem.item == 'money' then
                xPlayer.addMoney(qty)
                TriggerClientEvent('ox_lib:notify', src, { title = _U('pickpocket_success_title'), description = _U('stolen_money', qty), type = 'success' })
            else
                if exports.ox_inventory:CanCarryItem(src, selectedItem.item, qty) then
                    exports.ox_inventory:AddItem(src, selectedItem.item, qty)
                    TriggerClientEvent('ox_lib:notify', src, { title = _U('pickpocket_success_title'), description = _U('stolen_item', qty, _U(selectedItem.label)), type = 'success' })
                else
                    TriggerClientEvent('ox_lib:notify', src, { title = _U('pockets_full'), description = _U('pockets_full_desc'), type = 'error' })
                end
            end
        end
    end)
end)
