---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_clarity",
    "item_clarity",
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
	"item_energy_booster",

    "item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

    "item_blink",

    "item_ring_of_protection",
	"item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_aghanims_shard",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_robe",
    "item_staff_of_wizardry",
	"item_recipe_kaya",

    "item_platemail",
    "item_mystic_staff",
    "item_recipe_shivas_guard",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_eagle",
    "item_recipe_swift_blink",

    "item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",
	"item_void_stone",
	"item_void_stone",
	"item_recipe_octarine_core",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
