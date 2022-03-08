extends Reference
class_name Artifacts

## Artifacts that are used immediately when picked.
const CONSUMED := [
	"Golden Chalice",
	"Health Potion",
]

const NAMES := [
	"Dragon Egg",
	"Golden Chalice",
	"Health Potion",
	"Power Gauntlets",
	"Winged Boots",
]

const TABLE := {
	"Dragon Egg": preload("res://components/backpack/artifacts/dragon_egg/dragon_egg.tscn"),
	"Golden Chalice": preload("res://components/backpack/artifacts/golden_chalice/golden_chalice.tscn"),
	"Health Potion": preload("res://components/backpack/artifacts/health_potion/health_potion.tscn"),
	"Power Gauntlets": preload("res://components/backpack/artifacts/power_gauntlets/power_gauntlets.tscn"),
	"Winged Boots": preload("res://components/backpack/artifacts/winged_boots/winged_boots.tscn"),
}

static func random_treasures(backpack) -> Array:
	var pool := []
	for name in NAMES:
		if not backpack.artifact_at_max_level(name):
			pool.append(name)
	pool.shuffle()
	var got := []
	for i in 3:
		if pool.size() == 0 or backpack.is_full():
			got.append(CONSUMED[randi() % CONSUMED.size()])
		elif pool.size() == 1:
			got.append(pool.pop_back())
		else:
			# Pull two, prefer the consumed option.
			var cand: String = pool.pop_back()
			if cand in CONSUMED:
				got.append(cand)
			else:
				got.append(pool.pop_back())
	return got
