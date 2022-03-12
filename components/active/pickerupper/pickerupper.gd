extends Component
class_name Pickerupper

const NAME := "Pickerupper"

signal picked_up(other)

export var free_on_pickup := false

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	var turn_taker: TurnTaker = entity.get_component("TurnTaker")
	if turn_taker:
		_ignore = turn_taker.connect("manual_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var epos := entity.grid_position
	var ents := entity_system.get_entities(epos.x, epos.y)
	for ent in ents:
		if ent == entity:
			continue
		var pickupable: Pickupable = ent.get_component(Pickupable.NAME)
		if pickupable:
			emit_signal("picked_up", pickupable)
			pickupable.pickup(self)
