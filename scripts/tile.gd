extends Reference
class_name Tile

enum {
	CHASM,
	WALL,
	FLOOR,
	
	# Not displayed.
	ABYSS_WALL,
	ABYSS_FLOOR,
	
	# Tiles used only for generation.
	LAVA,
	GOLD,
}

enum Property {
	BLOCKS_MOVEMENT,
	BLOCKS_LIGHT,
}

const LIST := [
	[false, false],
	[true, true],
	[false, false],
	
	[true, true],
	[false, false],
]
