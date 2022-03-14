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

func add_effect(scene: PackedScene, gpos: Vector2, color: int=-1, amount_scale: float=1.0) -> void:
	add_effect_global(scene, gpos * Constants.CELL_SIZE, color, amount_scale)

func add_effect_global(scene: PackedScene, pos: Vector2, color: int=-1, amount_scale: float=1.0) -> void:
	var effect: Effect = scene.instance()
	effect.position = pos
	if color >= 0:
		effect.color = color
	effect.amount_scale = amount_scale
	effects_node.add_child(effect)
