---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_quelling_blade",

	"item_magic_wand",

	"item_wraith_band",

	"item_power_treads",

	"item_vanguard",

	"item_bfury",

	"item_black_king_bar",

	"item_basher",
	"item_abyssal_blade",

	"item_lifesteal",

	"item_aghanims_shard",

	"item_nullifier",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_satanic",

	"item_travel_boots",
	"item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end

-- "item_monkey_king_bar",

-- Old version
--[[ local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_quelling_blade",
	"item_branches",
	"item_branches",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_lifesteal",
	"item_broadsword",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_cornucopia",
	"item_broadsword",
	"item_claymore",
	"item_recipe_bfury",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_javelin",
	"item_blitz_knuckles",
	"item_demon_edge",
	"item_recipe_monkey_king_bar",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_lifesteal",
    "item_claymore",
    "item_reaver",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
