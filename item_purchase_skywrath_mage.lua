---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_clarity",

	"item_clarity",

	"item_magic_wand",

	"item_null_talisman",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_rod_of_atos",

	"item_kaya",

	"item_pers",
	"item_sphere",

	"item_sange",

	"item_aghanims_shard",

	"item_ultimate_scepter",

	"item_blink",

	"item_ultimate_scepter_2",

	"item_maelstrom",
	"item_gungir",

	"item_arcane_blink",

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
	"item_clarity",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

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

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_aghanims_shard",

	"item_blink",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_robe",
	"item_staff_of_wizardry",
	"item_recipe_kaya",

	"item_recipe_ultimate_scepter_2",

	"item_belt_of_strength",
	"item_ogre_axe",
	"item_recipe_sange",

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_recipe_gungir",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
