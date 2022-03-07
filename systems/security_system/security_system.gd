extends Node2D
class_name SecuritySystem

##
## This system manages dragonlings and waking them up.
##

const GROUP_NAME := "security_system"

var asleep_dragons := {}
var awake_dragons := {}

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func add_dragon(dragon) -> void:
	asleep_dragons[dragon] = true
	dragon.connect("woke_up", self, "_on_dragon_woke_up", [dragon])

func remove_dragon(dragon) -> void:
	var _ignore
	_ignore = asleep_dragons.erase(dragon)
	_ignore = awake_dragons.erase(dragon)

func _on_dragon_woke_up(dragon) -> void:
	var _ignore
	_ignore = asleep_dragons.erase(dragon)
	awake_dragons[dragon] = true
