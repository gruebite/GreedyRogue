extends Reference
class_name Artifacts

## Artifacts that are used immediately when picked.
const CONSUMED := [
	"Golden Chalice",
	"Health Potion",
	"Heart Piece",
	"Liquid Courage",
]

const NAMES := [
	"Ankh",
	"Balanced Stick",
	"Chaos Shard",
	"Dragon Egg",
	"Golden Chalice",
	"Health Potion",
	"Heart Piece",
	"Liquid Courage",
	"Power Bracelet",
	"Sandglass",
	"Winged Boots",
]

const TABLE := {
	"Ankh": preload("res://components/reactive/backpack/artifacts/ankh/ankh.tscn"),
	"Balanced Stick": preload("res://components/reactive/backpack/artifacts/balanced_stick/balanced_stick.tscn"),
	"Chaos Shard": preload("res://components/reactive/backpack/artifacts/chaos_shard/chaos_shard.tscn"),
	"Dragon Egg": preload("res://components/reactive/backpack/artifacts/dragon_egg/dragon_egg.tscn"),
	"Golden Chalice": preload("res://components/reactive/backpack/artifacts/golden_chalice/golden_chalice.tscn"),
	"Health Potion": preload("res://components/reactive/backpack/artifacts/health_potion/health_potion.tscn"),
	"Heart Piece": preload("res://components/reactive/backpack/artifacts/heart_piece/heart_piece.tscn"),
	"Liquid Courage": preload("res://components/reactive/backpack/artifacts/liquid_courage/liquid_courage.tscn"),
	"Power Bracelet": preload("res://components/reactive/backpack/artifacts/power_bracelet/power_bracelet.tscn"),
	"Sandglass": preload("res://components/reactive/backpack/artifacts/sandglass/sandglass.tscn"),
	"Winged Boots": preload("res://components/reactive/backpack/artifacts/winged_boots/winged_boots.tscn"),
}

static func random_treasures(backpack) -> Array:
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
