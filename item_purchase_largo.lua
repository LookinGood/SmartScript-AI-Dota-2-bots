---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_clarity",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_bracer",

    "item_ring_of_basilius",
    "item_arcane_boots",

    "item_pavise",
    "item_solar_crest",

    "item_headdress",
    "item_mekansm",

    "item_aghanims_shard",

    "item_guardian_greaves",

    "item_headdress",
    "item_pipe",

    "item_pers",
    "item_lotus_orb",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_veil_of_discord",
    "item_shivas_guard",

    "item_soul_booster",
    "item_octarine_core",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
