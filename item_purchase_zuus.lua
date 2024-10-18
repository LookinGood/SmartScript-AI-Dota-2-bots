---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_clarity",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_null_talisman",

	"item_power_treads",

	"item_oblivion_staff",
	"item_witch_blade",

	"item_phylactery",

	"item_force_staff",
	"item_dragon_lance",
	"item_hurricane_pike",

	"item_aghanims_shard",

	"item_devastator",

	"item_lesser_crit",
	"item_angels_demise",

	"item_kaya",
	"item_sange",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_arcane_blink",

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
	"item_flask",
	"item_clarity",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_wind_lace",
	"item_boots",
	"item_ring_of_regen",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_recipe_boots_of_bearing",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_point_booster",
	"item_diadem",
	"item_recipe_phylactery",

	"item_aghanims_shard",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_recipe_angels_demise",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_blink",

	"item_cornucopia",
	"item_ring_of_tarrasque",
	"item_tiara_of_selemene",
	"item_recipe_refresher",

	"item_recipe_ultimate_scepter_2",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",
} ]]
