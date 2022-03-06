extends Component
class_name Dam

const NAME := "Dam"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.connect("moved", self, "_on_moved")

func _on_moved(_from: Vector2, to: Vector2) -> void:
	var ents := entity_system.get_entities(to.x, to.y)
	for ent in ents:
		var dammable: Dammable = ent.get_component(Dammable.NAME)
		if dammable:
			dammable.entity.queue_free()
			entity.queue_free()
