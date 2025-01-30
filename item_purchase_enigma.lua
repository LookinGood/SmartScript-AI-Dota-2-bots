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

	"item_soul_ring",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_glimmer_cape",

	"item_blink",

	"item_pers",
	"item_sphere",

	"item_soul_booster",
	"item_bloodstone",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_arcane_blink",

	"item_refresher",

	"item_aghanims_shard",

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
	"item_enchanted_mango",
	"item_flask",

	"item_recipe_magic_wand",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
	"item_recipe_arcane_boots",

    "item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_aghanims_shard",

	"item_blink",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_cornucopia",
	"item_ring_of_tarrasque",
    "item_tiara_of_selemene",
	"item_recipe_refresher",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
