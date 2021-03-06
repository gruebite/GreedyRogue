extends Component
class_name Harming

const NAME := "Harming"

signal harmed(other)

export var immediate := false
export var triggers_death := false
export var damage := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("taken_turns", self, "_on_taken_turns")
	if turn_taker:
		_ignore = turn_taker.connect("take_inturn", self, "_on_taken_turns")
	if immediate:
		_on_taken_turns()

func _on_taken_turns() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		if ent == entity:
			continue
		var harmable: Harmable = ent.get_component(Harmable.NAME)
		if harmable:
			emit_signal("harmed", harmable)
			harmable.harm(self)
			if triggers_death:
				entity.kill("kamakazee")
