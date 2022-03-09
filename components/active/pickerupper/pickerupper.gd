extends Component
class_name Pickerupper

const NAME := "Pickerupper"

signal picked_up(entity)

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("in_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var epos := entity.grid_position
	var ents := entity_system.get_entities(epos.x, epos.y)
	for ent in ents:
		if ent == entity:
			continue
		var pickupable: Pickupable = ent.get_component(Pickupable.NAME)
		if pickupable:
			pickupable.pickup(entity)
			emit_signal("picked_up", ent)
			# TODO: Is this necessary?  Can we have something else handle this?
			ent.queue_free()