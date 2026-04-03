---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_faerie_fire",

    "item_magic_wand",

    "item_bracer",

    "item_phase_boots",

    "item_ultimate_scepter",

    "item_black_king_bar",

    "item_blink",

    "item_basher",
    "item_sange",
    "item_abyssal_blade",

    "item_aghanims_shard",

    "item_ultimate_scepter_2",

    "item_lesser_crit",
    "item_greater_crit",

    "item_moon_shard",

    "item_swift_blink",

    "item_satanic",

    "item_travel_boots",
    "item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
