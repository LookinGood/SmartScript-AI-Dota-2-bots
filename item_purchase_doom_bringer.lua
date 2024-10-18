---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_clarity",

    "item_faerie_fire",

    "item_magic_wand",

    "item_bracer",

    "item_phase_boots",

    "item_hand_of_midas",

    "item_veil_of_discord",

    "item_black_king_bar",

    "item_aghanims_shard",

    "item_shivas_guard",

    "item_ultimate_scepter",

    "item_overwhelming_blink",

    "item_ultimate_scepter_2",

    "item_soul_booster",
    "item_octarine_core",

    "item_moon_shard",

    "item_radiance",

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
    "item_clarity",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_gloves",
	"item_recipe_hand_of_midas",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_blink",

    "item_aghanims_shard",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_hyperstone",
	"item_hyperstone",

    "item_talisman_of_evasion",
	"item_relic",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}
 ]]
