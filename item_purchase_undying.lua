---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_clarity",

    "item_enchanted_mango",

    "item_magic_wand",

	"item_bracer",

    "item_soul_ring",

    "item_ring_of_basilius",
	"item_arcane_boots",

    "item_pavise",
	"item_solar_crest",

    "item_vanguard",
    "item_crimson_guard",

    "item_headdress",
	"item_mekansm",

	"item_buckler",
	"item_guardian_greaves",

    "item_sange",
    "item_heavens_halberd",

    "item_ultimate_scepter",

    "item_overwhelming_blink",

    "item_aghanims_shard",

    "item_ultimate_scepter_2",

    "item_soul_booster",
	"item_octarine_core",
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
    "item_clarity",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_ring_of_protection",
    "item_fluffy_hat",
    "item_energy_booster",
    "item_recipe_pavise",

    "item_wind_lace",
    "item_crown",
    "item_recipe_solar_crest",

    "item_cloak",
    "item_shadow_amulet",
    "item_recipe_glimmer_cape",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_chainmail",
    "item_recipe_mekansm",

    "item_ring_of_protection",
    "item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_helm_of_iron_will",
    "item_recipe_crimson_guard",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_aghanims_shard",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_talisman_of_evasion",
    "item_recipe_heavens_halberd",

    "item_recipe_ultimate_scepter_2",

    "item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",
} ]]
