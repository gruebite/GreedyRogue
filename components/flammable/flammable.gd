extends Component
class_name Flammable

const NAME := "Flammable"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var health: Health = entity.get_component(Health.NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("in_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		var fire: Flaming = ent.get_component(Flaming.NAME)
		if fire:
			health.health -= fire.heat
