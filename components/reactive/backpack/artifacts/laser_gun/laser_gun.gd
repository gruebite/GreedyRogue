extends Artifact

onready var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	for dir in Direction.COMPASS:
		var dv := Direction.delta(dir)
		var gpos: Vector2 = backpack.entity.grid_position + dv
		if navigation_system.is_lava(gpos.x, gpos.y):
			charge += 1
			break

func use(_dir: int) -> bool:
	return true
