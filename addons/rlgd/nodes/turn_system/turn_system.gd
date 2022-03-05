extends Node2D
class_name TurnSystem

##
## Turn system for turn-based games.
## 
## Should appear in the scene before any nodes that use it.
##

const GROUP_NAME := "turn_system"
const TURN_TAKER_GROUP_NAME := "turn_taker"

enum {
	OUT_OF_TURN,
	IN_TURN,
}

signal out_of_turn()
signal in_turn()

var state: int = OUT_OF_TURN

var _turn_takers := {}

static func instance(tree: SceneTree) -> Node2D:
	return tree.get_nodes_in_group(GROUP_NAME)[0]

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func _process(delta: float) -> void:
	if state == OUT_OF_TURN:
		return

	if _turn_takers.size() == 0:
		state = OUT_OF_TURN
		emit_signal("out_of_turn")

func taking_turn(node: Node2D) -> void:
	assert(state == IN_TURN, "can only take turn when in_turn")
	_turn_takers[node] = true

func finish_turn(node: Node2D) -> void:
	assert(state == IN_TURN, "can only finish turn when in_turn")
	_turn_takers.erase(node)

func can_initiate_turn() -> bool:
	return state == OUT_OF_TURN

func initiate_turn() -> void:
	assert(can_initiate_turn())
	state = IN_TURN
	emit_signal("in_turn")
	for tt in get_tree().get_nodes_in_group(TURN_TAKER_GROUP_NAME):
		tt.emit_signal("take_turn")
