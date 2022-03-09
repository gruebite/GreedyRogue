extends Artifact

onready var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir: int) -> bool:
	navigation_system.move_to(backpack.entity, navigation_system.find_random_unblocked())
	self.charge = 0
	return true
