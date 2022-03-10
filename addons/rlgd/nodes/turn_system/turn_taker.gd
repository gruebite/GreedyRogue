extends Node2D
class_name TurnTaker

## Connect when you do updates along with other turn takers.  Stuff like movement.
signal take_turn()
## Connect when you do updates selectively.  This should be for basic area checks.  An analog is in_turn.
signal manual_turn()

onready var system: TurnSystem = get_tree().get_nodes_in_group(TurnSystem.GROUP_NAME)[0]

func _ready() -> void:
	add_to_group(TurnSystem.TURN_TAKER_GROUP_NAME)

func _exit_tree() -> void:
	system.finish_turn(self)

func taking_turn() -> void:
	system.taking_turn(self)

func finish_turn() -> void:
	system.finish_turn(self)
