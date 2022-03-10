extends Artifact

onready var navigation_system: NavigationSystem

onready var bright: Bright

func _ready() -> void:
	if backpack:
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)
		bright = backpack.entity.get_component(Bright.NAME)

func _on_out_of_turn() -> void:
	var gpos: Vector2 = backpack.entity.grid_position
	if navigation_system.is_near_lava(gpos.x, gpos.y):
		charge += max_charges[level] * 0.1
	
	self.charge -= 1
	
	if charge == 0:
		bright.unglow()
	else:
		var dim := (level + 1) * 3
		var lit := (level + 1) * 1
		bright.glow(dim, lit)
