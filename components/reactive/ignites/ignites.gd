extends Component
class_name Ignites

const NAME := "Ignites"

signal ignited(by)
signal put_out()

export var immune := false
export var eternal := false
## -1 represents no fuel
export var fuel := -1
export var ignited := false

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.get_component(Flammable.NAME).connect("burned", self, "_on_burned")
	_ignore = turn_system.connect("initiated_turn", self, "_on_initiated_turn")

func _on_burned(by: Flaming) -> void:
	if not immune and not ignited:
		ignited = true
		emit_signal("ignited", by)

func _on_initiated_turn() -> void:
	if ignited:
		var gpos := entity.grid_position
		var _ignore = entity_system.spawn_entity(preload("res://entities/fire/fire.tscn"), gpos)
	if eternal or fuel == -1:
		return
	if fuel == 0:
		emit_signal("put_out")
		fuel = -1
	else:
		fuel -= 1
