extends Node2D
class_name HoardSystem

const GROUP_NAME := "hoard_system"

signal gold_added()
signal gold_removed()
signal gold_collected()

var gold_p setget , get_gold_p
var gold_piles_remaining := 0
var gold_piles_collected := 0

var piles := {}

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func reset() -> void:
	# We don't reset remaining because it should be managed automatically via `add_gold/remove_gold`
	gold_piles_collected = 0
	piles.clear()

func add_gold(pile) -> void:
	piles[pile] = true
	gold_piles_remaining += 1
	emit_signal("gold_added")

func remove_gold(pile) -> void:
	var _ignore = piles.erase(pile)
	gold_piles_remaining -= 1
	emit_signal("gold_removed")

func collect_gold() -> void:
	gold_piles_collected += 1
	emit_signal("gold_collected")

func get_gold_p() -> float:
	var total_gold := gold_piles_remaining + gold_piles_collected
	if total_gold == 0:
		return 1.0
	return float(gold_piles_collected) / total_gold
