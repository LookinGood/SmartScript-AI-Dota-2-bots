---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_blight_stone",
	"item_branches",
	"item_branches",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_circlet",
    "item_sobi_mask",
    "item_ring_of_protection",
    "item_recipe_urn_of_shadows",

	"item_mithril_hammer",
	"item_mithril_hammer",

	"item_fluffy_hat",
    "item_crown",
    "item_recipe_spirit_vessel",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

	"item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_aghanims_shard",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

	"item_hyperstone",
	"item_hyperstone",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
