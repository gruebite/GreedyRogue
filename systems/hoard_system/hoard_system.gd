extends Node2D
class_name HoardSystem

const GROUP_NAME := "hoard_system"

signal treasure_added()
signal treasure_removed()

var gold_p setget , get_gold_p
var gold_remaining := 0
var gold_collected := 0

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func reset() -> void:
	gold_remaining = 0
	gold_collected = 0

func add_treasure(t) -> void:
	gold_remaining += t.gold
	emit_signal("treasure_added")

func remove_treasure(t) -> void:
	gold_remaining -= t.gold
	emit_signal("treasure_removed")

func collect_gold(amount: int) -> void:
	gold_collected += amount

func get_gold_p() -> float:
	var total_gold := gold_remaining + gold_collected
	if total_gold == 0:
		return 1.0
	return float(gold_collected) / total_gold
