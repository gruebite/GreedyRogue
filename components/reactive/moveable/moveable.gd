extends Component
class_name Moveable

const NAME := "Moveable"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")

func _on_bumped(by: Bumper) -> void:
	var dv := entity.grid_position - by.entity.grid_position
	var desired := entity.grid_position + dv
	if navigation_system.can_move_to(entity, desired):
		navigation_system.move_to(entity, desired)
