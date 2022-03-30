extends Node2D
class_name TurnTaker

##
## TurnTaker node should be attached to any node that process per turn.
##

## Connect when you want to process a turn.  This is a place to do movement / animations.
signal take_turn()
## Connect when you want to process within a turn when say position could change (triggering a trap).
signal take_inturn()

onready var system: TurnSystem = get_tree().get_nodes_in_group(TurnSystem.GROUP_NAME)[0]

func _ready() -> void:
	add_to_group(TurnSystem.TURN_TAKER_GROUP_NAME)

func _exit_tree() -> void:
	system.finish_turn(self)

func taking_turn() -> void:
	system.taking_turn(self)

func finish_turn() -> void:
	system.finish_turn(self)
