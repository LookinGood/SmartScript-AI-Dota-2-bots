---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_enchanted_mango",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_null_talisman",

	"item_soul_ring",

	"item_boots",

	"item_aether_lens",

	"item_phylactery",

	"item_ultimate_scepter",

	"item_dagon",

	"item_angels_demise",

	"item_ethereal_blade",

	"item_pers",
	"item_sphere",

	"item_travel_boots",

	"item_aghanims_shard",

	"item_dagon_2",
	"item_dagon_3",
	"item_dagon_4",
	"item_dagon_5",

	"item_ultimate_scepter_2",

	"item_sheepstick",

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

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_voodoo_mask",
    "item_diadem",
	"item_recipe_dagon",

	"item_recipe_travel_boots",

	"item_blink",

	"item_aghanims_shard",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_tiara_of_selemene",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_recipe_travel_boots",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",
} ]]
