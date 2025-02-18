---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_orb_of_venom",

	"item_magic_wand",

	"item_bracer",

	"item_phase_boots",

	"item_orb_of_corrosion",

	"item_vanguard",

	"item_desolator",

	"item_sange",
	"item_yasha",

	"item_basher",
	"item_abyssal_blade",

	"item_radiance",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_aghanims_shard",

	"item_moon_shard",

	"item_buckler",
	"item_assault",

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
	"item_orb_of_venom",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

	"item_ring_of_protection",
	"item_gloves",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

	"item_belt_of_strength",
	"item_ogre_axe",
	"item_recipe_sange",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_aghanims_shard",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_platemail",
	"item_hyperstone",
	"item_recipe_assault",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_talisman_of_evasion",
	"item_relic",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
