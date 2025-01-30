---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_faerie_fire",

    "item_magic_wand",

    "item_bracer",

    "item_phase_boots",

    "item_blade_mail",

    "item_black_king_bar",

    "item_blink",

    "item_lesser_crit",
    "item_greater_crit",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_overwhelming_blink",

    "item_aghanims_shard",

    "item_moon_shard",

    "item_satanic",

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
    "item_enchanted_mango",
    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_chainmail",
    "item_broadsword",
    "item_recipe_blade_mail",

    "item_blink",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_talisman_of_evasion",
    "item_recipe_heavens_halberd",

    "item_mithril_hammer",
	"item_belt_of_strength",
	"item_recipe_basher",

	"item_recipe_abyssal_blade",

    "item_lifesteal",
    "item_claymore",
    "item_reaver",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

    "item_aghanims_shard",
} ]]
