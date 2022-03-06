extends Reference
class_name Tile

enum {
	# Tiles used only for generation.
	LAVA_SETTLED = -1,
	
	# Displayed tiles.
	CHASM,
	WALL,
	FLOOR,
	
	# Not displayed.
	ABYSS_CHASM,
	ABYSS_WALL,
	ABYSS_FLOOR,
	
	# Tiles used only for generation.
	LAVA_CARVING,
	GOLD,
	ROCK,
	PITFALL,
	STALAGMITE,
}

enum Property {
	BLOCKS_MOVEMENT,
	BLOCKS_LIGHT,
}

const LIST := [
	[true, false],
	[true, true],
	[false, false],
	
	[true, false],
	[true, true],
	[false, false],
]
