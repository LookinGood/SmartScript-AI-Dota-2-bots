---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
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
	"item_gloves",
	"item_boots_of_elves",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_gloves",
	"item_recipe_hand_of_midas",

	"item_cornucopia",
	"item_broadsword",
	"item_claymore",
	"item_recipe_bfury",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_ultimate_orb",
	"item_recipe_manta",

	"item_aghanims_shard",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_quarterstaff",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_demon_edge",
	"item_relic",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
