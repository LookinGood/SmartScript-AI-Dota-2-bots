---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_tango",

	"item_flask",

	"item_magic_wand",

	"item_wraith_band",

	"item_wraith_band",

	"item_power_treads",

	"item_diffusal_blade",

	"item_ultimate_scepter",

	"item_aghanims_shard",

	"item_yasha",
	"item_manta",

	"item_skadi",

	"item_butterfly",

	"item_ultimate_scepter_2",

	"item_disperser",

	"item_moon_shard",

	"item_heart",

	"item_travel_boots",
	"item_travel_boots_2",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
