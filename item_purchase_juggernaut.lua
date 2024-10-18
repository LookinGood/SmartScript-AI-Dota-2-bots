---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_wraith_band",

	"item_phase_boots",

	"item_maelstrom",

	"item_vanguard",

	"item_yasha",
	"item_manta",

	"item_aghanims_shard",

	"item_basher",
	"item_abyssal_blade",

	"item_ultimate_scepter",

	"item_mjollnir",

	"item_butterfly",

	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_swift_blink",

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
	"item_slippers",
	"item_recipe_wraith_band",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_gloves",
	"item_javelin",
	"item_mithril_hammer",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_aghanims_shard",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_diadem",
	"item_recipe_manta",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_hyperstone",
	"item_hyperstone",

	"item_blink",

	"item_eagle",
    "item_recipe_swift_blink",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
