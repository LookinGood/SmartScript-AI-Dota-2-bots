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

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_recipe_gungir",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_eagle",
	"item_recipe_disperser",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_point_booster",
	"item_ultimate_orb",
	"item_recipe_skadi",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
