extends Component
class_name Flaming

const NAME := "Flaming"

signal burned(other)

export var heat := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	var turn_taker: TurnTaker = entity.get_component("TurnTaker")
	if turn_taker:
		_ignore = turn_taker.connect("manual_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var flammable: Flammable = ent.get_component(Flammable.NAME)
		if flammable:
			emit_signal("burned", flammable)
			flammable.burn(self)
