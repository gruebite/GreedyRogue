extends Reference
class_name Grid

func _init() -> void:
	pass
	
func out_of_bounds(x: int, y: int) -> bool:
	assert(false, "not implemented")
	return false

func get_cell(x: int, y: int):
	assert(false, "not implemented")

func set_cell(x: int, y: int, val) -> void:
	assert(false, "not implemented")

func clear() -> void:
	assert(false, "not implemented")

func out_of_boundsv(v: Vector2) -> bool:
	return out_of_bounds(v.x, v.y)

func get_cellv(v: Vector2):
	return get_cell(v.x, v.y)

func set_cellv(v: Vector2, val) -> void:
	set_cell(v.x, v.y, val)

func set_point_set(ps: PointSet, offset_x: int, offset_y: int, val_func: FuncRef) -> void:
	set_point_setv(ps, Vector2(offset_x, offset_y), val_func)

func set_point_setv(ps: PointSet, offset: Vector2, val_func: FuncRef) -> void:
	for v in ps.array:
		var pos: Vector2 = v + offset
		if not out_of_boundsv(pos):
			set_cellv(pos, val_func.call_func())
