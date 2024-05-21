require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_flask",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

	"item_boots",
	"item_gloves",
	"item_belt_of_strength",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_gloves",
	"item_javelin",
	"item_mithril_hammer",

	"item_blade_of_alacrity",
	"item_belt_of_strength",
	"item_recipe_dragon_lance",

	"item_recipe_hurricane_pike",

	"item_blight_stone",
    "item_mithril_hammer",
	"item_mithril_hammer",

	"item_aghanims_shard",

	"item_blink",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_eagle",
    "item_recipe_swift_blink",

	"item_hyperstone",
    "item_hyperstone",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end

-- Support build
--[[ local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_aghanims_shard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

	"item_ring_of_protection",
	"item_recipe_buckler",

	"item_recipe_guardian_greaves",

	"item_blink",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_blade_of_alacrity",
	"item_belt_of_strength",
	"item_recipe_dragon_lance",

	"item_recipe_hurricane_pike",

	"item_reaver",
    "item_recipe_overwhelming_blink",

	"item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",
} ]]