require( GetScriptDirectory().."/item_purchase_generic" ) 

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

    "item_ring_of_regen",
    "item_recipe_headdress",

    "item_cloak",
    "item_ring_of_health",

    "item_recipe_pipe",

    "item_aghanims_shard",

    "item_vitality_booster",
    "item_recipe_spirit_vessel",

    "item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

    "item_sobi_mask",
    "item_recipe_ring_of_basilius",

    "item_crown",
    "item_recipe_veil_of_discord",

    "item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_voodoo_mask",
    "item_recipe_bloodstone",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots_2",

}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end