---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_orb_of_frost",

	"item_magic_wand",

	"item_wraith_band",

	"item_power_treads",

	"item_orb_of_corrosion",

	"item_diffusal_blade",

	"item_black_king_bar",

	"item_yasha",
	"item_manta",

	"item_lesser_crit",
	"item_greater_crit",

	"item_aghanims_shard",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_disperser",

	"item_moon_shard",

	"item_butterfly",

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

	"item_robe",
	"item_blade_of_alacrity",
	"item_recipe_diffusal_blade",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_boots_of_elves",
	"item_blade_of_alacrity",
	"item_recipe_yasha",

	"item_belt_of_strength",
	"item_ogre_axe",
	"item_recipe_sange",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_eagle",
	"item_recipe_disperser",

	"item_hyperstone",
	"item_hyperstone",

	"item_javelin",
	"item_blitz_knuckles",
	"item_demon_edge",
	"item_recipe_monkey_king_bar",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
