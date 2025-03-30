---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_enchanted_mango",

	"item_wind_lace",

	"item_magic_wand",

	"item_null_talisman",

	"item_tranquil_boots",

	"item_oblivion_staff",
	"item_witch_blade",

	"item_ancient_janggo",

	"item_oblivion_staff",
	"item_orchid",

	"item_boots_of_bearing",

	"item_aghanims_shard",

	"item_ultimate_scepter",

	"item_sheepstick",

	"item_ultimate_scepter_2",

	"item_devastator",

	"item_bloodthorn",

	"item_pers",
	"item_lotus_orb",

	"item_skadi",
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
	"item_wind_lace",
	"item_branches",
	"item_branches",
	"item_enchanted_mango",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_recipe_boots_of_bearing",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_chainmail",
	"item_recipe_witch_blade",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_cornucopia",
	"item_recipe_orchid",

	"item_aghanims_shard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_tiara_of_selemene",
	"item_mystic_staff",
	"item_recipe_sheepstick",

	"item_recipe_ultimate_scepter_2",

	"item_javelin",
	"item_hyperstone",
	"item_recipe_bloodthorn",

	"item_mystic_staff",
	"item_recipe_devastator",

	"item_point_booster",
	"item_ultimate_orb",
	"item_recipe_skadi",
} ]]
