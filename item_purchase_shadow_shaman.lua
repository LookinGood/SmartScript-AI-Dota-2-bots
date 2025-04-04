---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_clarity",

	"item_wind_lace",

	"item_magic_wand",

	"item_null_talisman",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_glimmer_cape",

	"item_aether_lens",

	"item_cyclone",

	"item_aghanims_shard",

	"item_pers",
	"item_sphere",

	"item_wind_waker",

	"item_ethereal_blade",

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
	"item_wind_lace",
	"item_branches",
	"item_branches",

	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_aghanims_shard",

	"item_blink",

	"item_recipe_boots_of_bearing",
	
	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_cornucopia",
	"item_ring_of_tarrasque",
    "item_tiara_of_selemene",
	"item_recipe_refresher",
} ]]
