---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_faerie_fire",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_wind_lace",
	"item_boots",
	"item_ring_of_regen",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_chainmail",
	"item_recipe_witch_blade",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_blink",

	"item_recipe_boots_of_bearing",

	"item_aghanims_shard",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

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

	"item_mystic_staff",
	"item_recipe_devastator",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_hyperstone",
	"item_hyperstone",

	"item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
