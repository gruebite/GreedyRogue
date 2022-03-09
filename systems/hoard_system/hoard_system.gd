extends Node2D
class_name HoardSystem

const GROUP_NAME := "hoard_system"

signal gold_added()
signal gold_removed()

var gold_p setget , get_gold_p
var gold_piles_remaining := 0
var gold_piles_collected := 0

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func reset() -> void:
	# We don't reset remaining because it should be managed automatically via `add_gold/remove_gold`
	gold_piles_collected = 0

func add_gold() -> void:
	gold_piles_remaining += 1
	emit_signal("gold_added")

func remove_gold() -> void:
	gold_piles_remaining -= 1
	emit_signal("gold_removed")

func collect_gold() -> void:
	gold_piles_collected += 1

func get_gold_p() -> float:
	var total_gold := gold_piles_remaining + gold_piles_collected
	if total_gold == 0:
		return 1.0
	return float(gold_piles_collected) / total_gold
