---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_faerie_fire",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_aghanims_shard",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_platemail",
    "item_recipe_shivas_guard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_void_stone",
    "item_voodoo_mask",

	"item_recipe_ultimate_scepter_2",

	"item_tiara_of_selemene",
	"item_mystic_staff",
	"item_recipe_sheepstick",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
