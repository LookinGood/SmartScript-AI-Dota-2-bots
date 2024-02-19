---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_clarity",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_gloves",
	"item_robe",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_aghanims_shard",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_chainmail",
	"item_recipe_witch_blade",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_mystic_staff",

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_recipe_gungir",

	"item_hyperstone",
	"item_hyperstone",

	"item_blade_of_alacrity",
	"item_belt_of_strength",
	"item_recipe_dragon_lance",

	"item_recipe_hurricane_pike",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
