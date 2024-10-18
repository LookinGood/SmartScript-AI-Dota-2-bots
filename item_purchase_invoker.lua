---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_faerie_fire",

    "item_magic_wand",

    "item_null_talisman",

    "item_phase_boots",

    "item_hand_of_midas",

    "item_oblivion_staff",
    "item_witch_blade",
    "item_devastator",

    "item_pers",
    "item_sphere",

    "item_aghanims_shard",

    "item_sheepstick",

    "item_oblivion_staff",
    "item_orchid",
    "item_bloodthorn",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_moon_shard",

    "item_soul_booster",
    "item_octarine_core",

    "item_travel_boots",
    "item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
