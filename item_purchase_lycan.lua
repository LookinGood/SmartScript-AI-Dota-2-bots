---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_orb_of_venom",
	"item_branches",
	"item_branches",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

	"item_blight_stone",
	"item_fluffy_hat",
	"item_recipe_orb_of_corrosion",

	"item_boots",
	"item_gloves",
	"item_belt_of_strength",

	"item_lifesteal",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_ring_of_protection",
	"item_recipe_buckler",

	"item_sobi_mask",
	"item_recipe_ring_of_basilius",

	"item_blades_of_attack",
	"item_recipe_vladmir",

	"item_helm_of_iron_will",
    "item_diadem",
    "item_recipe_helm_of_the_dominator",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_recipe_helm_of_the_overlord",

	"item_aghanims_shard",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_platemail",
	"item_hyperstone",
	"item_recipe_assault",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_demon_edge",
	"item_relic",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
