---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_enchanted_mango",

	"item_magic_wand",

	"item_wraith_band",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_diffusal_blade",

	"item_ultimate_scepter",

	"item_black_king_bar",

	"item_lesser_crit",
	"item_greater_crit",

	"item_aghanims_shard",

	"item_disperser",

	"item_overwhelming_blink",

	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_skadi",

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
	"item_orb_of_venom",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_ring_of_protection",
	"item_gloves",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_blink",

	"item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_eagle",
	"item_recipe_disperser",

	"item_eagle",
    "item_recipe_swift_blink",

	"item_hyperstone",
	"item_hyperstone",

	"item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}
 ]]
