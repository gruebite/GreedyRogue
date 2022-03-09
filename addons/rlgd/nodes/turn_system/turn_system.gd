extends Node2D
class_name TurnSystem

##
## Turn system for turn-based games.
##
## Should appear in the scene before any nodes that use it.
##

const GROUP_NAME := "turn_system"
const TURN_TAKER_GROUP_NAME := "turn_taker"

enum Step {
	INITIATED_TURN,
	TAKE_TURN,
	IN_TURN,
	OUT_OF_TURN,
}

enum {
	OUT_OF_TURN,
	IN_TURN,
}

## Emitted when the turn is first initiated, before signaling turn takers.
signal initiated_turn()
## Emitted after all the turn takers have been signaled.
signal in_turn()
## Emitted when all turn takers say they're finished, and a new turn can be initiated.
signal out_of_turn()

var disabled := false
var state: int = OUT_OF_TURN

var _turn_takers := {}

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func taking_turn(node: Node2D) -> void:
	assert(state == IN_TURN, "can only take turn when in_turn")
	_turn_takers[node] = true

func finish_turn(node: Node2D) -> void:
	var _ignore = _turn_takers.erase(node)
	if state == IN_TURN and _turn_takers.size() == 0:
		state = OUT_OF_TURN
		emit_signal("out_of_turn")

func can_initiate_turn() -> bool:
	return not disabled and state == OUT_OF_TURN

func will_initiate_turn() -> void:
	assert(can_initiate_turn())
	state = IN_TURN

func will_not_initiate_turn() -> void:
	state = OUT_OF_TURN

func initiate_turn() -> void:
	emit_signal("initiated_turn")
	taking_turn(self)
	# We yield to allow some effects to get processed if necessary (like queue_free)
	yield(get_tree(), "idle_frame")
	for tt in get_tree().get_nodes_in_group(TURN_TAKER_GROUP_NAME):
		tt.emit_signal("take_turn")
	yield(get_tree(), "idle_frame")
	emit_signal("in_turn")
	finish_turn(self)
