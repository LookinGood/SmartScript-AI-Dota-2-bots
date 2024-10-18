---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_wraith_band",

	"item_soul_ring",

	"item_power_treads",

	"item_echo_sabre",

	"item_oblivion_staff",
	"item_orchid",

	"item_yasha",
	"item_manta",

	"item_black_king_bar",

	"item_aghanims_shard",

	"item_bloodthorn",

	"item_harpoon",

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
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",
	"item_gloves",
	"item_boots_of_elves",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_cornucopia",
	"item_recipe_orchid",

    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_diadem",
	"item_recipe_manta",

	"item_diadem",
	"item_recipe_harpoon",

	"item_javelin",
	"item_hyperstone",
	"item_recipe_bloodthorn",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
