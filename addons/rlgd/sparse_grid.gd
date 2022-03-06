extends Grid
class_name SparseGrid

var cells := {}

func _init() -> void:
	pass

func out_of_bounds(x: int, y: int) -> bool:
	return false

func get_cell(x: int, y: int):
	return cells.get(Vector2(x, y))

func set_cell(x: int, y: int, val):
	cells[Vector2(x, y)] = val

func clear() -> void:
	cells.clear()
