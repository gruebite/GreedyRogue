extends Reference
class_name Tile

enum {
	CHASM,
	WALL,
	FLOOR,
}

enum Property {
	BLOCKS_MOVEMENT,
	BLOCKS_LIGHT,
}

const LIST := [
	[true, false],
	[true, true],
	[false, false],
]
