---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
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

	"item_blight_stone",
	"item_fluffy_hat",
    "item_recipe_orb_of_corrosion",

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

	"item_quarterstaff",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_javelin",
	"item_blitz_knuckles",
	"item_demon_edge",
	"item_recipe_monkey_king_bar",

	"item_demon_edge",
	"item_relic",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_demon_edge",
	"item_recipe_disperser",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
