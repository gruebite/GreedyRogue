extends Node2D
class_name EffectSystem

##
## This system manages dragonlings and waking them up.
##

const GROUP_NAME := "effect_system"

export var effects_node_path := NodePath("../Effects")

onready var effects_node := get_node(effects_node_path)

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func add_effect(scene: PackedScene, pos: Vector2) -> void:
	var effect: Effect = scene.instance()
	effect.position = pos
	effects_node.add_child(effect)
