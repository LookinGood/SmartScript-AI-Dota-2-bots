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

    "item_blade_mail",

    "item_kaya",
    "item_sange",

    "item_headdress",
    "item_mekansm",
    "item_buckler",
    "item_guardian_greaves",

    "item_aghanims_shard",

    "item_veil_of_discord",
    "item_shivas_guard",

    "item_pers",
    "item_lotus_orb",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_soul_booster",
    "item_bloodstone",
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
	"item_mantle",
	"item_recipe_null_talisman",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
    "item_recipe_soul_ring",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_chainmail",
    "item_broadsword",
    "item_recipe_blade_mail",

    "item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

    "item_ring_of_protection",
	"item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_aghanims_shard",

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

    "item_voodoo_mask",
	"item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_bloodstone",
} ]]
