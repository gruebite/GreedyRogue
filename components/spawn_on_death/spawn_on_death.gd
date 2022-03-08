extends Component
class_name SpawnOnDeath

const NAME := "SpawnOnDeath"

export(PackedScene) var spawns

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.connect("died", self, "_on_died")

func _on_died(_by: Node2D) -> void:
	if spawns:
		entity_system.add_entity(spawns.instance(), entity.grid_position)
