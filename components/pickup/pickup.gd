extends Component
class_name Pickup

const NAME := "Pickup"

signal picked_up(entity)

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

func _ready() -> void:
	# Out of turn because pickups may execute logic which depends on a turn being finished, like
	# recovering anxiety or health.
	var _ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")

func _on_out_of_turn() -> void:
	var epos := entity.grid_position
	var ents := entity_system.get_entities(epos.x, epos.y)
	for ent in ents:
		if ent.get_component(Pickupable.NAME):
			emit_signal("picked_up", ent)
			ent.queue_free()
