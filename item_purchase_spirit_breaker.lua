---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_orb_of_venom",
	"item_branches",
	"item_branches",
	"item_faerie_fire",
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

	"item_shadow_amulet",
	"item_blitz_knuckles",
	"item_broadsword",

    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_demon_edge",
	"item_recipe_silver_edge",

	"item_aghanims_shard",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_demon_edge",
	"item_relic",

	"item_blink",

	"item_recipe_travel_boots",
	"item_boots",

	"item_eagle",
    "item_recipe_swift_blink",

	"item_recipe_travel_boots",

	"item_diadem",
	"item_recipe_harpoon",

	"item_hyperstone",
	"item_hyperstone",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end