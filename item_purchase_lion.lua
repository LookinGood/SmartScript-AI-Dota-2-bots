require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_wind_lace",
	"item_branches",
	"item_branches",

	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_blink",

	"item_aghanims_shard",

	"item_sobi_mask",
	"item_diadem",
	"item_point_booster",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_voodoo_mask",
	"item_diadem",
	"item_recipe_dagon",

	"item_recipe_boots_of_bearing",

	"item_recipe_dagon",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
