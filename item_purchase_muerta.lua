---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_null_talisman",

	"item_power_treads",

	"item_maelstrom",

	"item_dragon_lance",
	"item_specialists_array",

	"item_lesser_crit",

	"item_hydras_breath",

	"item_black_king_bar",

	"item_aghanims_shard",

	"item_greater_crit",

	"item_mjollnir",

	"item_ultimate_scepter",
	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_kaya",
	"item_yasha",

	"item_travel_boots",
	"item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
