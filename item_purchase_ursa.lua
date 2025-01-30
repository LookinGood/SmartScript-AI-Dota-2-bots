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

    "item_diffusal_blade",

    "item_black_king_bar",

    "item_blink",

    "item_lifesteal",

    "item_basher",
    "item_vanguard",
    "item_abyssal_blade",

    "item_aghanims_shard",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_disperser",

    "item_swift_blink",

    "item_moon_shard",

    "item_satanic",

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

	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",

    "item_blink",

    "item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_aghanims_shard",

    "item_lifesteal",
    "item_claymore",
    "item_reaver",

    "item_eagle",
    "item_recipe_swift_blink",

    "item_eagle",
	"item_recipe_disperser",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
