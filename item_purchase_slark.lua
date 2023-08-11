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
	"item_gloves",
	"item_boots_of_elves",

	"item_sobi_mask",
	"item_robe",
	"item_quarterstaff",
	"item_ogre_axe",

	"item_cornucopia",
	"item_ultimate_orb",
	"item_recipe_sphere",

	"item_aghanims_shard",

	"item_broadsword",
	"item_blades_of_attack",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_ring_of_health",
	"item_vitality_booster",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_diadem",
	"item_recipe_harpoon",

	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_demon_edge",
	"item_relic",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
