extends Component
class_name Tripper

const NAME := "Tripper"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.connect("moved", self, "_on_entity_moved")
	var turn_taker: TurnTaker = entity.get_component("TurnTaker")
	if turn_taker:
		_ignore = turn_taker.connect("manual_turn", self, "_on_in_turn")

func _on_entity_moved(_from: Vector2) -> void:
	_on_in_turn()

func _on_in_turn() -> void:
	var gpos: Vector2 = entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var trippable: Trippable = ent.get_component(Trippable.NAME)
		if trippable:
			trippable.trip(entity)
