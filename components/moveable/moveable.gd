extends Component
class_name Moveable

const NAME := "Moveable"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")

func _on_bumped(by: Entity) -> void:
	var dv := entity.grid_position - by.grid_position
	var desired := entity.grid_position + dv
	if navigation_system.can_move_to(desired):
		entity.move(desired)
		entity_system.update_entity(entity)
