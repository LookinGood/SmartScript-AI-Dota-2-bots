---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
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
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
