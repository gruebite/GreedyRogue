extends Component
class_name Grounded

const NAME := "Grounded"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.connect("moved", self, "_on_entity_moved")

func _on_entity_moved(_from: Vector2, to: Vector2) -> void:
	var ents := entity_system.get_entities(to.x, to.y)
	for ent in ents:
		var tripwire: Tripwire = ent.get_component(Tripwire.NAME)
		if tripwire:
			tripwire.trip(entity)
