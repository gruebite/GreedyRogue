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
