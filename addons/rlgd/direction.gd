extends Reference
class_name Direction

enum {
	EAST,
	NORTHEAST,
	NORTH,
	NORTHWEST,
	WEST,
	SOUTHWEST,
	SOUTH,
	SOUTHEAST,
}

const CARDINALS = [EAST, NORTH, WEST, SOUTH]
const DIAGONALS = [NORTHEAST, NORTHWEST, SOUTHWEST, SOUTHEAST]
const COMPASS = [
	EAST,
	NORTHEAST,
	NORTH,
	NORTHWEST,
	WEST,
	SOUTHWEST,
	SOUTH,
	SOUTHEAST,
]

static func delta(dir: int) -> Vector2:
	match dir:
		EAST: return Vector2(1, 0)
		NORTHEAST: return Vector2(1, -1)
		NORTH: return Vector2(0, -1)
		NORTHWEST: return Vector2(-1, -1)
		WEST: return Vector2(-1, 0)
		SOUTHWEST: return Vector2(-1, 1)
		SOUTH: return Vector2(0, 1)
		SOUTHEAST: return Vector2(1, 1)
	return Vector2.ZERO

static func angle_to_cardinal_direction(phi: float) -> int:
	var east := 0.0
	var south := PI / 2
	var west := PI
	var north := PI * (3.0 / 2.0)

	var dist_east := abs(atan2(sin(east - phi), cos(east - phi)))
	if dist_east <= PI / 4:
		return EAST
	var dist_south := abs(atan2(sin(south - phi), cos(south - phi)))
	if dist_south <= PI / 4:
		return SOUTH
	var dist_west := abs(atan2(sin(west - phi), cos(west - phi)))
	if dist_west <= PI / 4:
		return WEST
	return NORTH

static func is_cardinal(dir: int) -> bool:
	match dir:
		EAST: return true
		NORTH: return true
		WEST: return true
		SOUTH: return true
	return false

static func is_diagonal(dir: int) -> bool:
	match dir:
		NORTHEAST: return true
		NORTHWEST: return true
		SOUTHWEST: return true
		SOUTHEAST: return true
	return false

static func opposite(dir: int) -> int:
	return (dir + 4) % 8

static func cardinal_left(dir: int) -> int:
	return (dir + 6) % 8

static func cardinal_right(dir: int) -> int:
	return (dir + 2) % 8
