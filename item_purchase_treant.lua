require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_flask",
	"item_clarity",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",
	"item_energy_booster",

	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_void_stone",
	"item_ring_of_health",
	"item_crown",
	"item_recipe_meteor_hammer",

	"item_aghanims_shard",

	"item_blink",

	"item_ring_of_protection",
	"item_recipe_buckler",

	"item_recipe_guardian_greaves",

	"item_platemail",
	"item_mystic_staff",
	"item_recipe_shivas_guard",

	"item_cornucopia",
	"item_cornucopia",
	"item_recipe_refresher",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
