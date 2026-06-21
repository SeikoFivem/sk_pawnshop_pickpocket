Config = {}

-- 🌍 Langue (fr, en, es, it, de)
Config.Locale = 'fr'

function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return "Translation [" .. Config.Locale .. "][" .. str .. "] does not exist"
    end
end

-- 📍 Configuration du PNJ (Recéleur)
Config.PedModel = "g_m_y_salvagoon_01" -- Modèle du PNJ (Apparence)
Config.PedCoords = vector4(295.0781, -1005.4921, 29.3353, 358.4893) -- Coordonnées (x, y, z, heading) - Par défaut: Une ruelle vers Little Seoul
Config.BlipName = _U('ui_title') -- Nom sur la carte (Mettre nil ou false pour ne pas avoir de blip)
Config.BlipSprite = 662 -- Icône du blip (Optionnel)

-- 💰 Configuration de la vente
Config.PaymentType = "money" -- "money" (Liquide), "bank" (Banque), ou "black_money" (Argent Sale)

-- 📦 Liste des objets qu'il rachète
-- minLevel : Niveau de réputation requis pour vendre cet objet
Config.ItemsToSell = {
    { label = "rolex_label",      item = "rolex",     price = 600,  minLevel = 1 },
    { label = "gold_ring_label",  item = "gold_ring", price = 300,  minLevel = 1 },
    { label = "gold_chain_label", item = "gold_chain", price = 250,  minLevel = 1 },
    { label = "iphone_label",     item = "iphone",    price = 150,  minLevel = 1 },
    { label = "diamond_label",    item = "diamond",   price = 1200, minLevel = 2 }, -- Niveau 2 requis !
}

-- 📈 Système de Réputation
Config.Reputation = {
    Enabled = true,
    XpPerSale = 5, -- XP gagnée par objet vendu
    
    -- Paliers de niveaux (XP requise pour atteindre le niveau)
    Levels = {
        [1] = 0,    -- Débutant
        [2] = 200,  -- Intermédiaire (Débloque Diamants)
        [3] = 1000, -- Boss (Pour le futur)
    },
    
    Labels = {
        [1] = "rep_1",
        [2] = "rep_2",
        [3] = "rep_3"
    }
}

-- ⚙️ Textes (Ceux-ci sont conservés pour compatibilité mais utilisent maintenant _U)
Config.Text = {
    PressToTalk = _U('press_to_talk'),
    MenuTitle = _U('menu_title'),
    Sell = _U('sell'),
    For = _U('for'),
    NoItem = _U('no_item'),
    Sold = _U('sold'),
    Received = _U('received')
}

-- 🕵️ Configuration du Pickpocket (Vol à la tire)
Config.Pickpocket = {
    Enabled = true,
    Cooldown = 1000 * 60 * 5, -- Temps (ms) avant de pouvoir re-voler le MEME pnj (5 min) - Note: Le script gère par entité locale
    SuccessChance = 60, -- % de chance de réussir le skillcheck (Si implémenté)
    FindChance = 70, -- % de chance de trouver un objet (sinon "Poches vides")
    AlertPoliceChance = 50, -- % de chance que la police soit alertée en cas d'échec
    
    -- Temps d'animation (progress bar)
    Duration = 3500,

    -- Liste des objets qu'on peut trouver
    Loot = {
        -- item = nom de l'item, min = qté min, max = qté max, chance = Poids relatif (plus c'est haut, plus c'est commun)
        { item = "money",     label = "money_label",      min = 15, max = 200, chance = 50 }, -- Très commun (50%)
        { item = "burger",    label = "burger_label",     min = 1,  max = 1,   chance = 25 }, -- Commun (25%)
        { item = "iphone",    label = "iphone_label",     min = 1,  max = 1,   chance = 12 }, -- Peu commun (12%)
        { item = "gold_ring", label = "gold_ring_label",  min = 1,  max = 1,   chance = 8 },  -- Rare (8%)
        { item = "gold_chain",label = "gold_chain_label", min = 1,  max = 1,   chance = 4 },  -- Très Rare (4%)
        { item = "rolex",     label = "rolex_label",      min = 1,  max = 1,   chance = 1 },  -- Légendaire (1%)
        { item = "diamond",   label = "diamond_label",    min = 1,  max = 1,   chance = 1, minLevel = 2 }, -- Ultra Légendaire (1% & Niveau 2 requis)
    }
}
