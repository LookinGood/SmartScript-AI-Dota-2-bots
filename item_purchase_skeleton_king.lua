---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_faerie_fire",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_bracer",

	"item_soul_ring",

	"item_phase_boots",

	"item_armlet",

	"item_desolator",

	"item_blink",

	"item_aghanims_shard",

	"item_black_king_bar",

	"item_sange",
	"item_basher",
	"item_abyssal_blade",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_overwhelming_blink",

	"item_moon_shard",

	"item_radiance",

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
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",
	"item_blades_of_attack",
	"item_chainmail",

	"item_belt_of_strength",
	"item_ogre_axe",
	"item_recipe_sange",
	"item_talisman_of_evasion",
	"item_recipe_heavens_halberd",

	"item_aghanims_shard",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_blink",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_recipe_ultimate_scepter_2",

	"item_reaver",
	"item_recipe_overwhelming_blink",

	"item_hyperstone",
	"item_hyperstone",

	"item_talisman_of_evasion",
	"item_relic",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
