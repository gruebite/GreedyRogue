extends Component
class_name Spawner

const NAME := "Spawner"

export var unique := true
export var count := 1
export(NodePath) var effect_player_node_path
export(PackedScene) var spawns
export var on_ready := false
export var on_initiated_turn := false
export var on_take_turn := false
export var on_taken_turns := false
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
	if on_taken_turns:
		_ignore = turn_system.connect("taken_turns", self, "spawn")
	if on_out_of_turn:
		_ignore = turn_system.connect("out_of_turn", self, "spawn")
	if on_died:
		_ignore = entity.connect("died", self, "_on_died")
	if on_ready:
		spawn()

func _on_died(_source: String) -> void:
	spawn()

func spawn() -> void:
	if not spawns:
		return

	var gpos := entity.grid_position
	var c := 1 if unique else count
	var spawned := false
	for i in c:
		spawned = entity_system.spawn_entity(spawns, gpos, unique)
	if spawned and effect_player_node_path:
		 get_node(effect_player_node_path).play()
