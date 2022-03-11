extends Reference
class_name Artifacts

## Artifacts that are used immediately when picked.
const CONSUMED := [
	"Golden Chalice",
	"Health Potion",
	"Heart Piece",
	"Liquid Courage",
	"Map Fragment",
]

const NAMES := [
	"Amulet of Resolve",
	"Ancient War Mask",
	"Ankh",
	"Balanced Staff",
	"Broken Compass",
	"Chaos Shard",
	"Dragon Egg",
	"Ethereal Cloak",
	"Excalibur",
	"Fire Stone",
	"Golden Chalice",
	"Health Potion",
	"Heart Piece",
	"Horned Helm",
	"Laser Gun",
	"Liquid Courage",
	"Map Fragment",
	"Power Bracelet",
	"Ring of Power",
	"Sandglass",
	"Star in a Bottle",
	"Winged Boots",
]

const TABLE := {
	"Amulet of Resolve": preload("res://components/reactive/backpack/artifacts/amulet_of_resolve/amulet_of_resolve.tscn"),
	"Ancient War Mask": preload("res://components/reactive/backpack/artifacts/ancient_war_mask/ancient_war_mask.tscn"),
	"Ankh": preload("res://components/reactive/backpack/artifacts/ankh/ankh.tscn"),
	"Balanced Staff": preload("res://components/reactive/backpack/artifacts/balanced_staff/balanced_staff.tscn"),
	"Broken Compass": preload("res://components/reactive/backpack/artifacts/broken_compass/broken_compass.tscn"),
	"Chaos Shard": preload("res://components/reactive/backpack/artifacts/chaos_shard/chaos_shard.tscn"),
	"Dragon Egg": preload("res://components/reactive/backpack/artifacts/dragon_egg/dragon_egg.tscn"),
	"Ethereal Cloak": preload("res://components/reactive/backpack/artifacts/ethereal_cloak/ethereal_cloak.tscn"),
	"Excalibur": preload("res://components/reactive/backpack/artifacts/excalibur/excalibur.tscn"),
	"Fire Stone": preload("res://components/reactive/backpack/artifacts/fire_stone/fire_stone.tscn"),
	"Golden Chalice": preload("res://components/reactive/backpack/artifacts/golden_chalice/golden_chalice.tscn"),
	"Health Potion": preload("res://components/reactive/backpack/artifacts/health_potion/health_potion.tscn"),
	"Heart Piece": preload("res://components/reactive/backpack/artifacts/heart_piece/heart_piece.tscn"),
	"Horned Helm": preload("res://components/reactive/backpack/artifacts/horned_helm/horned_helm.tscn"),
	"Laser Gun": preload("res://components/reactive/backpack/artifacts/laser_gun/laser_gun.tscn"),
	"Liquid Courage": preload("res://components/reactive/backpack/artifacts/liquid_courage/liquid_courage.tscn"),
	"Map Fragment": preload("res://components/reactive/backpack/artifacts/map_fragment/map_fragment.tscn"),
	"Power Bracelet": preload("res://components/reactive/backpack/artifacts/power_bracelet/power_bracelet.tscn"),
	"Ring of Power": preload("res://components/reactive/backpack/artifacts/ring_of_power/ring_of_power.tscn"),
	"Sandglass": preload("res://components/reactive/backpack/artifacts/sandglass/sandglass.tscn"),
	"Star in a Bottle": preload("res://components/reactive/backpack/artifacts/star_in_a_bottle/star_in_a_bottle.tscn"),
	"Winged Boots": preload("res://components/reactive/backpack/artifacts/winged_boots/winged_boots.tscn"),
}

static func random_artifacts(backpack) -> Array:
	var pool: Array
	if backpack.is_full():
		pool = CONSUMED.duplicate()
	else:
		pool = []
		for name in NAMES:
			if not backpack.artifact_at_max_level(name):
				pool.append(name)
	pool.shuffle()
	var got := []
	for i in 3:
		if pool.size() == 0:
			got.append(CONSUMED[randi() % CONSUMED.size()])
		else:
			got.append(pool.pop_back())
	return got
