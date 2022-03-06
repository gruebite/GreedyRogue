extends Component
class_name Flammable

const NAME := "Flammable"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

onready var health: Health = entity.get_component(Health.NAME)

func _ready() -> void:
	var _ignore = entity.connect("moved", self, "_on_entity_moved")

func _on_entity_moved(_from: Vector2, to: Vector2) -> void:
	var ents := entity_system.get_entities(to.x, to.y)
	for ent in ents:
		var fire: Flaming = ent.get_component(Flaming.NAME)
		if fire:
			health.health -= fire.heat
