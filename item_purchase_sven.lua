---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_bracer",

	"item_power_treads",

	"item_mask_of_madness",

	"item_echo_sabre",

	"item_black_king_bar",

	"item_blink",

	"item_lesser_crit",
	"item_greater_crit",

	"item_aghanims_shard",

	"item_harpoon",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_overwhelming_blink",

	"item_moon_shard",

	"item_heart",

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
	"item_gauntlets",
	"item_recipe_bracer",

	"item_boots",
	"item_blades_of_attack",
	"item_chainmail",

	"item_lifesteal",
	"item_broadsword",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",
	
    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

	"item_blink",

	"item_aghanims_shard",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_reaver",
	"item_recipe_overwhelming_blink",

	"item_diadem",
	"item_recipe_harpoon",

	"item_hyperstone",
	"item_hyperstone",

	"item_lifesteal",
    "item_claymore",
    "item_reaver",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
