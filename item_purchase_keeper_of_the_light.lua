---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_magic_wand",

	"item_null_talisman",

	"item_tranquil_boots",

	"item_urn_of_shadows",
	"item_spirit_vessel",

	"item_oblivion_staff",
	"item_orchid",

	"item_dagon",

	"item_aether_lens",
	"item_ethereal_blade",

	"item_dagon_2",
	"item_dagon_3",
	"item_dagon_4",
	"item_dagon_5",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_bloodthorn",

	"item_soul_booster",
	"item_octarine_core",

	"item_travel_boots",
	"item_travel_boots_2",

	"item_aghanims_shard",
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
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_recipe_boots_of_bearing",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_aghanims_shard",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_voodoo_mask",
	"item_diadem",
	"item_recipe_dagon",

	"item_tiara_of_selemene",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_recipe_ultimate_scepter_2",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",

	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",
}
 ]]
