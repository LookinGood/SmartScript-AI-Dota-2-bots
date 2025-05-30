---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",

	"item_flask",

	"item_orb_of_frost",

	"item_magic_wand",

	"item_wraith_band",

	"item_phase_boots",

	"item_orb_of_corrosion",

	"item_echo_sabre",

	"item_black_king_bar",

	"item_sange",
	"item_basher",
	"item_abyssal_blade",

	"item_lesser_crit",
	"item_greater_crit",

	"item_harpoon",

	"item_ultimate_scepter",

	"item_aghanims_shard",

	"item_ultimate_scepter_2",

	"item_moon_shard",

	"item_butterfly",

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
	"item_orb_of_venom",
	"item_enchanted_mango",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_slippers",
	"item_recipe_wraith_band",

	"item_ring_of_protection",
	"item_gloves",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

	"item_ring_of_health",
	"item_vitality_booster",

    "item_ogre_axe",
    "item_broadsword",
    "item_void_stone",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_diadem",
	"item_recipe_harpoon",

	"item_hyperstone",
	"item_hyperstone",

	"item_claymore",
	"item_talisman_of_evasion",
	"item_eagle",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
} ]]
