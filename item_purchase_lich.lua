require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_wind_lace",
	"item_branches",
	"item_branches",
	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_wind_lace",
	"item_belt_of_strength",
	"item_robe",
	"item_recipe_ancient_janggo",

	"item_recipe_boots_of_bearing",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

	"item_aghanims_shard",

	"item_cornucopia",
	"item_ring_of_tarrasque",
	"item_tiara_of_selemene",
	"item_recipe_refresher",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",

	"item_recipe_ultimate_scepter_2",

	"item_gloves",
	"item_mithril_hammer",
	"item_javelin",

	"item_recipe_gungir",

	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
