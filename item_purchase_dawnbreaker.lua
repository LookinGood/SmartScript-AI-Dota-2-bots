---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_enchanted_mango",
    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",
    
    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

    "item_belt_of_strength",
	"item_ogre_axe",
	"item_recipe_sange",

	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",

    "item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_aghanims_shard",

    "item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

    "item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

    "item_diadem",
	"item_recipe_harpoon",

	"item_hyperstone",
	"item_hyperstone",

    "item_blink",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end


--[[ "item_sobi_mask",
"item_robe",
"item_blitz_knuckles",
"item_cloak",
"item_recipe_mage_slayer", ]]