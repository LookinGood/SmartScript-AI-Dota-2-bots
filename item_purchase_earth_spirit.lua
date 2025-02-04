---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_bracer",

    "item_ring_of_basilius",
    "item_arcane_boots",

    "item_urn_of_shadows",
    "item_spirit_vessel",

    "item_kaya",
    "item_sange",

    "item_veil_of_discord",
    "item_shivas_guard",

    "item_pers",
    "item_lotus_orb",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_soul_booster",
    "item_octarine_core",

    "item_travel_boots",
    "item_travel_boots_2",

    "item_aghanims_shard",
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

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_sobi_mask",
    "item_ring_of_protection",
    "item_fluffy_hat",
    "item_recipe_urn_of_shadows",

    "item_vitality_booster",
    "item_recipe_spirit_vessel",

    "item_staff_of_wizardry",
    "item_robe",
    "item_recipe_kaya",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_ring_of_health",
    "item_void_stone",
    "item_energy_booster",
    "item_platemail",
    "item_recipe_lotus_orb",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

    "item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",

    "item_aghanims_shard",
} ]]
