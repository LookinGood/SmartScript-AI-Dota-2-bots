---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_clarity",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_circlet",
	"item_sobi_mask",
	"item_ring_of_protection",
	"item_recipe_urn_of_shadows",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_aghanims_shard",

	"item_vitality_booster",
	"item_recipe_spirit_vessel",

	"item_blink",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots_2",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
