extends Node2D
class_name Entity

var grid_position: Vector2 setget set_grid_position, get_grid_position

func set_grid_position(value: Vector2) -> void:
	position = value * Constants.CELL_SIZE

func get_grid_position() -> Vector2:
	return (position / Constants.CELL_SIZE).floor()

func get_component(path: String) -> Node2D:
	return find_node(path) as Node2D
