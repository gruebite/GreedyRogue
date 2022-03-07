extends Node2D
class_name SecuritySystem

##
## This system manages dragonlings and waking them up.
##

const GROUP_NAME := "security_system"

var total_dragons := 0
var asleep_dragons := {}
var awake_dragons := {}
var gold_p := 0.0 setget set_gold_p

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func _on_dragon_woke_up(dragon) -> void:
	var _ignore
	_ignore = asleep_dragons.erase(dragon)
	awake_dragons[dragon] = true

func add_dragon(dragon) -> void:
	total_dragons += 1
	asleep_dragons[dragon] = true
	dragon.connect("woke_up", self, "_on_dragon_woke_up", [dragon])

func remove_dragon(dragon) -> void:
	var _ignore
	_ignore = asleep_dragons.erase(dragon)
	_ignore = awake_dragons.erase(dragon)

func set_gold_p(value: float) -> void:
	gold_p = value
	var asleep := asleep_dragons.keys()
	asleep.shuffle()
	var dragons_p: float = 1 - (asleep.size() / float(total_dragons))
	while dragons_p < gold_p:
		asleep.pop_back().wake_up()
		dragons_p = 1 - (asleep.size() / float(total_dragons))
