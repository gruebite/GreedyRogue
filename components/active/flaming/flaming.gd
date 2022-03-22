extends Component
class_name Flaming

const NAME := "Flaming"

signal burned(other)

export var damage := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("taken_turns", self, "_on_taken_turns")
	var turn_taker: TurnTaker = entity.get_component("TurnTaker")
	if turn_taker:
		_ignore = turn_taker.connect("take_inturn", self, "_on_taken_turns")

func _on_taken_turns() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var flammable: Flammable = ent.get_component(Flammable.NAME)
		if flammable:
			emit_signal("burned", flammable)
			flammable.burn(self)
