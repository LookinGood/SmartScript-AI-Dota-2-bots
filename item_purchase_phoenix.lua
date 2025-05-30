---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_bracer",

	"item_tranquil_boots",

	"item_urn_of_shadows",

	"item_ancient_janggo",

	"item_spirit_vessel",

	"item_boots_of_bearing",

	"item_veil_of_discord",
	"item_shivas_guard",

	"item_vanguard",
	"item_heavens_halberd",

	"item_heart",

	"item_ultimate_scepter",

	"item_aghanims_shard",

	"item_ultimate_scepter_2",

	"item_radiance",
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
	"item_wind_lace",
	"item_branches",
	"item_branches",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

    "item_boots",
    "item_ring_of_regen",

	"item_sobi_mask",
	"item_ring_of_protection",
	"item_fluffy_hat",
	"item_recipe_urn_of_shadows",

    "item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

    "item_recipe_boots_of_bearing",

	"item_vitality_booster",
	"item_recipe_spirit_vessel",

	"item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_ring_of_health",
	"item_void_stone",
	"item_energy_booster",
	"item_platemail",
	"item_recipe_lotus_orb",

	"item_talisman_of_evasion",
	"item_relic",

	"item_recipe_ultimate_scepter_2",

	"item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

	"item_aghanims_shard",
} ]]
