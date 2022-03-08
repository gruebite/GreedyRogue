extends Component
class_name Harmful

const NAME := "Harmful"

export var immediate := false
export var damage := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore = turn_taker.connect("take_turn", self, "_on_take_turn")
	if immediate:
		_on_take_turn()

func _on_take_turn() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var health: Health = ent.get_component(Health.NAME)
		if health:
			health.health -= damage
