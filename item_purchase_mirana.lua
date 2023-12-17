---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_boots",
	"item_gloves",
	"item_boots_of_elves",

	"item_mithril_hammer",
	"item_javelin",

	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_recipe_gungir",

	"item_cornucopia",
	"item_ultimate_orb",
	"item_recipe_sphere",

	"item_quarterstaff",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_demon_edge",
	"item_relic",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_demon_edge",
	"item_recipe_disperser",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
