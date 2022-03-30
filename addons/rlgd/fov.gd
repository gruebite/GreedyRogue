extends Reference
class_name Fov

## Anything <= 0 is blocking, anything > 0 is unblocking.
enum Clarity {
	NONE,
	FULL,
}

## Anything <= 0 is unlit, anything > 0 is lit.
enum Sight {
	NONE,
	FULL,
}

##
## Shadow Cast field of view implementation.
##

enum { _XX, _XY, _YX, _YY }

const _TRANSFORMS = [
	# xx, xy, yx, yy
	[ 1,  0,  0,  1],
	[ 1,  0,  0, -1],
	[-1,  0,  0,  1],
	[-1,  0,  0, -1],
	[ 0,  1,  1,  0],
	[ 0,  1, -1,  0],
	[ 0, -1,  1,  0],
	[ 0, -1, -1,  0],
]

## Recursive Shadow Cast
static func shadow_cast(tile_grid: Grid, light_grid: Grid, origin: Vector2, radius: int) -> void:
	if not tile_grid.out_of_boundsv(origin):
		light_grid.set_cellv(origin, 1)
	for i in range(8):
		_shadow_cast(tile_grid, light_grid, _TRANSFORMS[i], origin, radius, 1, 1, 1, 0, 1)

static func _shadow_cast(tile_grid: Grid, light_grid: Grid, trans: Array, origin: Vector2, radius: int, xx: int, top_y: int, top_x: int, bottom_y: int, bottom_x: int) -> void:
	for x in range(xx, radius + 1):
		var new_top_y: int = 0
		if top_x == 1:
			new_top_y = x
		else:
			new_top_y = ((x * 2 + 1) * top_y + top_x - 1) / (top_x * 2)
		var new_bottom_y: int = 0
		if bottom_y == 0:
			new_bottom_y = 0
		else:
			new_bottom_y = ((x * 2 - 1) * bottom_y + bottom_x) / (bottom_x * 2)

		var was_opaque := -1
		for y in range(new_top_y, new_bottom_y - 1, -1):
			var realx = origin.x + trans[_XX] * x + trans[_XY] * y
			var realy = origin.y + trans[_YX] * x + trans[_YY] * y
			var realv := Vector2(realx, realy)
			if tile_grid.out_of_boundsv(realv):
				continue
			var in_range := radius < 0 || origin.distance_squared_to(realv) <= radius * radius
			if in_range && (y != new_top_y || top_y * x >= top_x * y) && (y != new_bottom_y || bottom_y * x <= bottom_x * y):
				light_grid.set_cellv(realv, Sight.FULL)

			var tile = tile_grid.get_cellv(realv)
			if tile == null: tile = 0
			var is_opaque: bool = !in_range || tile <= Clarity.NONE
			if x != radius:
				if is_opaque:
					if was_opaque == 0:
						var new_y := y * 2 + 1
						var new_x := x * 2 - 1
						if !in_range || y == new_bottom_y:
							bottom_y = new_y
							bottom_x = new_x
							break
						else:
							_shadow_cast(tile_grid, light_grid, trans, origin, radius, x + 1, top_y, top_x, new_y, new_x)
					was_opaque = 1
				else:
					if was_opaque > 0:
						top_y = y * 2 + 1
						top_x = x * 2 + 1
					was_opaque = 0
		if was_opaque != 0:
			break
