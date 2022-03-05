extends Grid
class_name DenseGrid

var width: int
var height: int
var cells := []

func _init(width: int, height: int):
	self.width = width
	self.height = height
	cells.resize(width * height)

func out_of_bounds(x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= width or y >= height

func get_cell(x: int, y: int):
	return cells[y * width + x]

func set_cell(x: int, y: int, val):
	cells[y * width + x] = val

func clear() -> void:
	cells.clear()
	cells.resize(width * height)
