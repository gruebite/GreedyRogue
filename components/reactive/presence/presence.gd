extends Component
class_name Presence

const NAME := "Presence"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	entity_system.update_entity(entity)
	var _ignore = entity.connect("moved", self, "_on_moved")

func _exit_tree() -> void:
	entity_system.unregister_entity(entity)

func _on_moved(_from: Vector2) -> void:
	entity_system.update_entity(entity)
