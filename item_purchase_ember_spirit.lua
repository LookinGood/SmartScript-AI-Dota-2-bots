---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_quelling_blade",

	"item_magic_wand",

	"item_wraith_band",

	"item_phase_boots",

	"item_bfury",

	"item_maelstrom",

	"item_black_king_bar",

	"item_lesser_crit",
	"item_greater_crit",

	"item_aghanims_shard",

	"item_mjollnir",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

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
	"item_quelling_blade",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_cornucopia",
	"item_broadsword",
	"item_claymore",
	"item_recipe_bfury",

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_talisman_of_evasion",
	"item_relic",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_aghanims_shard",
} ]]

--"item_talisman_of_evasion",
--"item_relic",
