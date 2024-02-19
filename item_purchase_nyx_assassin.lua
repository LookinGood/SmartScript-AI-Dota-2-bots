require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_enchanted_mango",

    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_mantle",
    "item_recipe_null_talisman",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_circlet",
    "item_sobi_mask",
    "item_ring_of_protection",
    "item_recipe_urn_of_shadows",

    "item_voodoo_mask",
    "item_diadem",
    "item_recipe_dagon",

    "item_staff_of_wizardry",
    "item_robe",
    "item_recipe_kaya",

    "item_recipe_dagon",

    "item_aghanims_shard",

    "item_recipe_dagon",

    "item_fluffy_hat",
    "item_crown",
    "item_recipe_spirit_vessel",

    "item_recipe_dagon",

    "item_recipe_dagon",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_ring_of_health",
	"item_void_stone",
    "item_ultimate_orb",
    "item_recipe_sphere",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_tiara_of_selemene",
	"item_ultimate_orb",
	"item_mystic_staff",

    "item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
