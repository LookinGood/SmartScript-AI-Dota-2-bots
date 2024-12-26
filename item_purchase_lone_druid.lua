---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_faerie_fire",

	"item_magic_wand",

	"item_wraith_band",

	"item_power_treads",

	"item_diffusal_blade",

	"item_maelstrom",

	"item_black_king_bar",

	"item_rod_of_atos",

	"item_ultimate_scepter",

	"item_gungir",

	"item_disperser",

	"item_buckler",
	"item_assault",

	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_butterfly",

	"item_travel_boots",
	"item_travel_boots_2",

	"item_aghanims_shard",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
