extends Reference
class_name PointSet

##
## Maintains a random access set of points.
##

var array := []

func _init(arr: Array=[]) -> void:
	array = arr

func has(x: int, y: int) -> bool:
	return hasv(Vector2(x, y))

func hasv(pos: Vector2) -> bool:
	var idx := array.bsearch(pos)
	return idx < len(array) && array[idx] == pos

func length() -> int:
	return len(array)

func clear() -> void:
	array.clear()

func add(x: int, y: int) -> void:
	var pos := Vector2(x, y)
	addv(pos)

func addv(pos: Vector2) -> void:
	var idx := array.bsearch(pos)
	if idx < len(array) && array[idx] == pos:
		return
	array.insert(idx, pos)

func extend(arr: Array) -> void:
	for v in arr:
		addv(v)

func remove(x: int, y: int) -> void:
	var pos := Vector2(x, y)
	removev(pos)

func removev(pos: Vector2) -> void:
	var idx := array.bsearch(pos)
	if idx < len(array) && array[idx] == pos:
		array.remove(idx)

func random(rng: RandomNumberGenerator) -> Vector2:
	var i = rng.randi_range(0, len(array) - 1)
	return array[i]
