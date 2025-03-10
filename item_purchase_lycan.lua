---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_bracer",

	"item_power_treads",

	"item_helm_of_the_dominator",

	"item_echo_sabre",

	"item_black_king_bar",

	"item_helm_of_the_overlord",

	"item_sange",
	"item_basher",
	"item_abyssal_blade",

	"item_yasha",
	"item_manta",

	"item_aghanims_shard",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_harpoon",

	"item_moon_shard",

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
	"item_gloves",
	"item_belt_of_strength",

	"item_ring_of_health",
	"item_vitality_booster",

    "item_helm_of_iron_will",
    "item_diadem",
    "item_recipe_helm_of_the_dominator",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_ultimate_orb",
    "item_recipe_helm_of_the_overlord",

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

	"item_lifesteal",
    "item_claymore",
    "item_reaver",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_aghanims_shard",
}
 ]]
