extends Node2D
class_name TurnTaker

signal take_turn()

onready var system: TurnSystem = TurnSystem.instance(get_tree())

func _ready() -> void:
	add_to_group(TurnSystem.TURN_TAKER_GROUP_NAME)

func taking_turn() -> void:
	system.taking_turn(self)

func finish_turn() -> void:
	system.finish_turn(self)
