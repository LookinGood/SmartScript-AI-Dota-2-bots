---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_faerie_fire",
    "item_clarity",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_blink",

    "item_aghanims_shard",

    "item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",
	"item_void_stone",
	"item_void_stone",
	"item_recipe_octarine_core",

    "item_platemail",
    "item_mystic_staff",
    "item_recipe_shivas_guard",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_hyperstone",
	"item_hyperstone",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
