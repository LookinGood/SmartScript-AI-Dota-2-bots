---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_faerie_fire",
	"item_branches",
	"item_branches",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_boots",
	"item_gloves",
	"item_boots_of_elves",

	"item_lifesteal",
	"item_broadsword",

	"item_shadow_amulet",
	"item_blitz_knuckles",
	"item_broadsword",

	"item_blade_of_alacrity",
	"item_belt_of_strength",
	"item_recipe_dragon_lance",

	"item_demon_edge",
	"item_recipe_silver_edge",

	"item_aghanims_shard",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_diadem",
	"item_recipe_manta",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_recipe_hurricane_pike",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_hyperstone",

	"item_point_booster",
	"item_ultimate_orb",
	"item_recipe_skadi",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
