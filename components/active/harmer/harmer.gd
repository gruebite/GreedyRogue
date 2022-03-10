extends Component
class_name Harmer

const NAME := "Harmer"

export var immediate := false
export var triggers_death := false
export var damage := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	if turn_taker:
		_ignore = turn_taker.connect("manual_turn", self, "_on_in_turn")
	if immediate:
		_on_in_turn()

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var harmable: Harmable = ent.get_component(Harmable.NAME)
		if harmable:
			harmable.harm(entity)
			if triggers_death:
				entity.kill("kamakazee")
