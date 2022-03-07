extends Component
class_name Presence

const NAME := "Presence"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	entity_system.update_entity(entity)

func _exit_tree() -> void:
	entity_system.remove_entity(entity)
