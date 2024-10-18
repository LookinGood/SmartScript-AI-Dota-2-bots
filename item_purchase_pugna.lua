---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_clarity",

	"item_magic_wand",

	"item_null_talisman",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_aether_lens",

	"item_kaya",

	"item_dagon",

	"item_sange",

	"item_pers",
	"item_sphere",

	"item_dagon_2",
	"item_dagon_3",
	"item_dagon_4",
	"item_dagon_5",

	"item_ultimate_scepter",

	"item_aghanims_shard",

	"item_ultimate_scepter_2",

	"item_ethereal_blade",

	"item_soul_booster",
	"item_octarine_core",

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

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
	"item_recipe_arcane_boots",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_robe",
	"item_staff_of_wizardry",
    "item_recipe_kaya",

	"item_voodoo_mask",
    "item_diadem",
    "item_recipe_dagon",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",
	
	"item_aghanims_shard",
}
 ]]
