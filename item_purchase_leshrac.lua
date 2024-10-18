---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_null_talisman",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_kaya",

	"item_soul_booster",
    "item_bloodstone",

	"item_sange",

	"item_aghanims_shard",

	"item_pers",
	"item_sphere",

	"item_sheepstick",

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
	"item_enchanted_mango",
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
	"item_robe",
	"item_recipe_kaya",

    "item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_void_stone",
    "item_voodoo_mask",

	"item_aghanims_shard",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_tiara_of_selemene",
	"item_mystic_staff",
	"item_recipe_sheepstick",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_blink",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
