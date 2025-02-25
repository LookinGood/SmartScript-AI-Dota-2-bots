---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_clarity",

    "item_enchanted_mango",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_soul_ring",

    "item_bracer",

    "item_phase_boots",

    "item_echo_sabre",

    "item_basher",

    "item_aghanims_shard",

    "item_harpoon",

    "item_heart",

    "item_sange",
    "item_abyssal_blade",

    "item_veil_of_discord",
    "item_shivas_guard",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_moon_shard",

    "item_soul_booster",
    "item_octarine_core",

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
 ]]
