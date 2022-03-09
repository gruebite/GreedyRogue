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
	"Dragon Egg",
	"Golden Chalice",
	"Health Potion",
	"Heart Piece",
	"Liquid Courage",
	"Power Gauntlets",
	"Winged Boots",
]

const TABLE := {
	"Dragon Egg": preload("res://components/reactive/backpack/artifacts/dragon_egg/dragon_egg.tscn"),
	"Golden Chalice": preload("res://components/reactive/backpack/artifacts/golden_chalice/golden_chalice.tscn"),
	"Health Potion": preload("res://components/reactive/backpack/artifacts/health_potion/health_potion.tscn"),
	"Heart Piece": preload("res://components/reactive/backpack/artifacts/heart_piece/heart_piece.tscn"),
	"Liquid Courage": preload("res://components/reactive/backpack/artifacts/liquid_courage/liquid_courage.tscn"),
	"Power Gauntlets": preload("res://components/reactive/backpack/artifacts/power_gauntlets/power_gauntlets.tscn"),
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
