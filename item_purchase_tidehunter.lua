---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_enchanted_mango",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_bracer",

    "item_soul_ring",

    "item_phase_boots",

    "item_blink",

    "item_desolator",

    "item_echo_sabre",

    "item_black_king_bar",

    "item_aghanims_shard",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_overwhelming_blink",

    "item_moon_shard",

    "item_lesser_crit",
    "item_greater_crit",

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

    "item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_blight_stone",
    "item_mithril_hammer",
	"item_mithril_hammer",

    "item_blink",

    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

    "item_aghanims_shard",

    "item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_diadem",
	"item_recipe_harpoon",

    "item_reaver",
	"item_recipe_overwhelming_blink",

    "item_hyperstone",
	"item_hyperstone",

    "item_cornucopia",
	"item_ring_of_tarrasque",
    "item_tiara_of_selemene",
	"item_recipe_refresher",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
