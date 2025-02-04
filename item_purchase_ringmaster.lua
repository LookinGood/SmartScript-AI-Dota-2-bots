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

	"item_oblivion_staff",
	"item_witch_blade",

	"item_kaya",
	"item_yasha",

	"item_aghanims_shard",

	"item_dagon",
	"item_dagon_2",
	"item_dagon_3",
	"item_dagon_4",
	"item_dagon_5",

	"item_maelstrom",
	"item_gungir",

	"item_devastator",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

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
	"item_clarity",
	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_sobi_mask",
	"item_recipe_ring_of_basilius",
	"item_recipe_arcane_boots",

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_chainmail",
	"item_recipe_witch_blade",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_aghanims_shard",

	"item_voodoo_mask",
	"item_diadem",
	"item_recipe_dagon",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_recipe_gungir",

	"item_mystic_staff",
	"item_recipe_devastator",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
