---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_faerie_fire",

    "item_magic_wand",

    "item_wraith_band",

    "item_power_treads",

    "item_oblivion_staff",
    "item_witch_blade",

    "item_force_staff",
    "item_dragon_lance",
    "item_hurricane_pike",

    "item_ultimate_scepter",

    "item_aghanims_shard",

    "item_skadi",

    "item_devastator",

    "item_butterfly",

    "item_ultimate_scepter_2",

    "item_moon_shard",

    "item_overwhelming_blink",

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
    "item_faerie_fire",
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

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

    "item_recipe_guardian_greaves",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

    "item_aghanims_shard",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_cloak",
    "item_ring_of_tarrasque",
    "item_recipe_pipe",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_void_stone",
    "item_voodoo_mask",
} ]]
