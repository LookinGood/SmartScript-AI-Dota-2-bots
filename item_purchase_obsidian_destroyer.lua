---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_faerie_fire",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_null_talisman",

	"item_null_talisman",

	"item_power_treads",

	"item_oblivion_staff",
	"item_witch_blade",

	"item_pers",
	"item_sphere",

	"item_kaya",
	"item_yasha",

	"item_aghanims_shard",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_devastator",

	"item_arcane_blink",

	"item_moon_shard",

	"item_lesser_crit",
	"item_revenants_brooch",

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
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_gloves",
	"item_robe",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_chainmail",
	"item_recipe_witch_blade",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_blink",

	"item_aghanims_shard",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_mystic_staff",
	"item_recipe_devastator",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_hyperstone",
	"item_hyperstone",

	"item_point_booster",
	"item_ultimate_orb",
	"item_recipe_skadi",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
