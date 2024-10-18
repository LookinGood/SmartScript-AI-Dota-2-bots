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

	"item_power_treads",

	"item_dragon_lance",

	"item_yasha",

	"item_force_staff",
	"item_hurricane_pike",

	"item_manta",

	"item_black_king_bar",

	"item_aghanims_shard",

    "item_skadi",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

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
	"item_enchanted_mango",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_boots",
	"item_gloves",
	"item_boots_of_elves",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_diadem",
	"item_recipe_manta",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_point_booster",
	"item_ultimate_orb",
	"item_recipe_skadi",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

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
