extends Component
class_name Spawner

const NAME := "Spawner"

export var unique := true
export var count := 1
export(PackedScene) var spawns
export var on_ready := false
export var on_initiated_turn := false
export var on_take_turn := false
export var on_in_turn := false
export var on_out_of_turn := false
export var on_died := false

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore
	if turn_taker and on_take_turn:
		_ignore = turn_taker.connect("take_turn", self, "spawn")
	if on_initiated_turn:
		_ignore = turn_system.connect("initiated_turn", self, "spawn")
	if on_in_turn:
		_ignore = turn_system.connect("in_turn", self, "spawn")
	if on_out_of_turn:
		_ignore = turn_system.connect("out_of_turn", self, "spawn")
	if on_died:
		_ignore = entity.connect("died", self, "_on_died")
	if on_ready:
		spawn()

func _on_died(_by: Entity) -> void:
	spawn()

func spawn() -> void:
	if not spawns:
		return

	var gpos := entity.grid_position
	var c := 1 if unique else count
	for i in c:
		entity_system.spawn_entity(spawns, gpos, unique)
