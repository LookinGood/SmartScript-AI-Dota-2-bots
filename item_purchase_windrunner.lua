---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_wraith_band",

	"item_power_treads",

	"item_maelstrom",

	"item_oblivion_staff",
	"item_orchid",

	"item_pers",
	"item_sphere",

	"item_lesser_crit",
	"item_greater_crit",

	"item_aghanims_shard",

	"item_bloodthorn",

	"item_mjollnir",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_yasha",
	"item_manta",

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
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_boots",
	"item_gloves",
	"item_boots_of_elves",

	"item_javelin",
	"item_gloves",
	"item_mithril_hammer",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_cornucopia",
	"item_recipe_orchid",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_aghanims_shard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_javelin",
	"item_hyperstone",
	"item_recipe_bloodthorn",

	"item_hyperstone",
	"item_hyperstone",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_diadem",
	"item_recipe_manta",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
