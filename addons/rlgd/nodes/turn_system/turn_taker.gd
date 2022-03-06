extends Node2D
class_name TurnTaker

signal take_turn()

onready var system: TurnSystem = get_tree().get_nodes_in_group(TurnSystem.GROUP_NAME)[0]

func _ready() -> void:
	add_to_group(TurnSystem.TURN_TAKER_GROUP_NAME)

func taking_turn() -> void:
	system.taking_turn(self)

func finish_turn() -> void:
	system.finish_turn(self)
