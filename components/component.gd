extends Node2D
class_name Component

onready var entity: Entity = get_parent()

func find_system(group_name) -> Node2D:
	return get_tree().get_nodes_in_group(group_name)[0]
