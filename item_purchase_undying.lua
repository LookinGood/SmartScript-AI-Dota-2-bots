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
    "item_clarity",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_energy_booster",

    "item_void_stone",
    "item_ring_of_protection",
    "item_fluffy_hat",
    "item_recipe_pavise",

    "item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_chainmail",
    "item_recipe_mekansm",

    "item_aghanims_shard",

    "item_helm_of_iron_will",
    "item_recipe_crimson_guard",

    "item_ring_of_protection",
    "item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_talisman_of_evasion",
    "item_recipe_heavens_halberd",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_void_stone",
    "item_void_stone",
    "item_recipe_octarine_core",

    "item_aghanims_shard",

    "item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
