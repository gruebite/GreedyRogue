extends Reference
class_name Tile

enum {
	# Tiles used only for generation.
	LAVA_SETTLED = -1,

	# Displayed tiles.
	WALL,
	FLOOR,
	CHASM,
	EXIT,

	# Not displayed.
	ABYSS_CHASM,
	ABYSS_WALL,
	ABYSS_FLOOR,

	# Tiles used only for generation.
	LAVA_CARVING,
	GOLD_PILE,
	TREASURE_CHEST,
	ROCK,
	PITFALL,
	STALAGMITE,
}

enum Property {
	BLOCKS_MOVEMENT,
	BLOCKS_LIGHT,
}

const LIST := [
	[true, true],
	[false, false],
	[false, false],
	[false, false],

	[true, false],
	[true, true],
	[false, false],
]
