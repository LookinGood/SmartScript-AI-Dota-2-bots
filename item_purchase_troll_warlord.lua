---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_faerie_fire",

    "item_magic_wand",

    "item_wraith_band",

    "item_phase_boots",

    "item_mask_of_madness",

    "item_yasha",
    "item_sange",

    "item_black_king_bar",

    "item_blink",

    "item_aghanims_shard",

    "item_lesser_crit",
    "item_greater_crit",

    "item_satanic",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_moon_shard",

    "item_swift_blink",

    "item_travel_boots",
    "item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end

-- Old version
--[[ local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_faerie_fire",
    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_slippers",
    "item_recipe_wraith_band",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_boots_of_elves",
    "item_blade_of_alacrity",
    "item_recipe_yasha",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_ogre_axe",
    "item_mithril_hammer",
    "item_recipe_black_king_bar",

    "item_aghanims_shard",

    "item_blink",

    "item_lifesteal",
    "item_claymore",
    "item_reaver",

    "item_eagle",
    "item_recipe_swift_blink",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_hyperstone",
    "item_hyperstone",

    "item_claymore",
    "item_talisman_of_evasion",
    "item_eagle",

    "item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",
} ]]
