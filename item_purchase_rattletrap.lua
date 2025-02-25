---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_bracer",

    "item_soul_ring",

    "item_ring_of_basilius",
    "item_arcane_boots",

    "item_urn_of_shadows",

    "item_blade_mail",

    "item_spirit_vessel",

    "item_vanguard",
    "item_heavens_halberd",

    "item_ultimate_scepter",

    "item_aghanims_shard",

    "item_ultimate_scepter_2",

    "item_soul_booster",
    "item_bloodstone",

    "item_heart",

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

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_ring_of_protection",
    "item_gauntlets",
    "item_gauntlets",
    "item_recipe_soul_ring",

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

    "item_chainmail",
    "item_broadsword",
    "item_recipe_blade_mail",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_aghanims_shard",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_recipe_ultimate_scepter_2",

    "item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

    "item_point_booster",
    "item_ultimate_orb",
    "item_recipe_skadi",

    "item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",
} ]]
