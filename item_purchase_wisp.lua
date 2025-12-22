---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_clarity",

	"item_magic_wand",

	"item_bracer",

	"item_ring_of_basilius",
	"item_arcane_boots",

	"item_holy_locket",

	"item_glimmer_cape",

	"item_headdress",
	"item_mekansm",
	"item_guardian_greaves",

	"item_pers",
	"item_lotus_orb",

	"item_ultimate_scepter",

	"item_heart",

	"item_ultimate_scepter_2",

	"item_sheepstick",

	"item_aghanims_shard",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end
