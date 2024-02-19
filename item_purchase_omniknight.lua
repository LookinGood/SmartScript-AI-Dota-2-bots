---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_enchanted_mango",
    "item_clarity",

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

    "item_ring_of_health",
    "item_vitality_booster",

    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

    "item_aghanims_shard",

    "item_diadem",
	"item_recipe_harpoon",

    "item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

    "item_recipe_abyssal_blade",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_hyperstone",
	"item_hyperstone",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
