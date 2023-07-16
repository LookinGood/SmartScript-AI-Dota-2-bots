---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_faerie_fire",
	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_flask",

	"item_recipe_soul_ring",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

	"item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_gloves",
	"item_recipe_hand_of_midas",

	"item_ring_of_health",
    "item_vitality_booster",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_vitality_booster",
    "item_reaver",
    "item_recipe_heart",

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_platemail",
	"item_hyperstone",
	"item_recipe_assault",

	"item_talisman_of_evasion",
	"item_relic",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
