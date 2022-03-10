extends Node2D
class_name GeneratorSystem

const GROUP_NAME := "generator_system"

const LEVEL_COUNT := 3
const LEVEL_MESSAGES := [
	"Entrance Chamber of the Dragon's Lair\n\nKnown for piles of gold and powerful artifacts",
	"Random Chamer of the Dragon's Lair",
	"Center Chamber of the Dragon's Lair",
]
const LEVEL_SETTINGS := [
	{
		"initial_open_p": 0.8,
		"initial_goto_edge_p": 0.25,
		"initial_random_walk_weight": 0.6,
		"secondary_open_p": 0.0,
		"secondary_open_radius": 0.0,
		"secondary_random_walk_weight": 0.0,

		"rock_count": 20,
		"pitfall_count": 5,
		"pitfall_size": 3,
		"stalagmite_count": 20,
		"small_lava_pool_count": 8,
		"small_lava_pool_size": 4,
		"large_lava_pool_count": 1,
		"large_lava_pool_size": 15,
		"lava_river_count": 0,
		"small_gold_pile_count": 10,
		"small_gold_pile_size": 3,
		"large_gold_pile_count": 3,
		"large_gold_pile_size": 10,
		"treasure_chest_count": 3,
		"dragonling_count": 3,
		"magma_slug_count": 1,
		"golem_count": 1,
		"tornado_count": 0,
	},
	{
		"initial_open_p": 0.7,
		"initial_goto_edge_p": 0.5,
		"initial_random_walk_weight": 0.6,
		"secondary_open_p": 0.8,
		"secondary_open_radius": 10.0,
		"secondary_random_walk_weight": 0.7,

		"rock_count": 20,
		"pitfall_count": 5,
		"pitfall_size": 9,
		"stalagmite_count": 20,
		"small_lava_pool_count": 3,
		"small_lava_pool_size": 4,
		"large_lava_pool_count": 2,
		"large_lava_pool_size": 15,
		"lava_river_count": 1,
		"small_gold_pile_count": 8,
		"small_gold_pile_size": 3,
		"large_gold_pile_count": 3,
		"large_gold_pile_size": 10,
		"treasure_chest_count": 5,
		"dragonling_count": 5,
		"magma_slug_count": 4,
		"golem_count": 5,
		"tornado_count": 0,
	},
	{
		"initial_open_p": 0.7,
		"initial_goto_edge_p": 0.8,
		"initial_random_walk_weight": 0.6,
		"secondary_open_p": 0.8,
		"secondary_open_radius": 10.0,
		"secondary_random_walk_weight": 0.7,

		"rock_count": 20,
		"pitfall_count": 5,
		"pitfall_size": 9,
		"stalagmite_count": 20,
		"small_lava_pool_count": 2,
		"small_lava_pool_size": 4,
		"large_lava_pool_count": 1,
		"large_lava_pool_size": 15,
		"lava_river_count": 2,
		"small_gold_pile_count": 10,
		"small_gold_pile_size": 3,
		"large_gold_pile_count": 1,
		"large_gold_pile_size": 10,
		"treasure_chest_count": 7,
		"dragonling_count": 7,
		"magma_slug_count": 4,
		"golem_count": 5,
		"tornado_count": 2,
	},
]

signal entered_level(lvl)

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")
onready var hoard_system: HoardSystem = get_node("../HoardSystem")
onready var bright_system: BrightSystem = get_node("../BrightSystem")
onready var navigation_system: NavigationSystem = get_node("../NavigationSystem")
onready var security_system: SecuritySystem = get_node("../SecuritySystem")

var generated_level := -1

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func generate(level: int=0, keep_player: bool=false) -> void:
	# Reset bright first because entity_system reset will add the player.
	bright_system.reset(keep_player)
	entity_system.reset(keep_player)
	hoard_system.reset()
	security_system.reset()

	var walker := Walker.new()
	walker.start(Constants.MAP_COLUMNS - 2, Constants.MAP_ROWS - 2)
	walker.pin(tile_to_walker_tile(Tile.LAVA_CARVING))

	var center := Vector2(Constants.MAP_COLUMNS / 2, Constants.MAP_ROWS / 2)

	# Center tile.
	walker.gotov(center)
	walker.mark(tile_to_walker_tile(Tile.FLOOR))
	walker.commit()

	yield()
	# Cavern structure.

	# Carves a general cave structure with a seed center by choosing random points on map
	# or on the edge.
	var plus := PointSets.plus()
	var initial_open_p: float = LEVEL_SETTINGS[level]["initial_open_p"]
	var initial_goto_edge_p: float = LEVEL_SETTINGS[level]["initial_goto_edge_p"]
	var initial_random_walk_weight: float = LEVEL_SETTINGS[level]["initial_random_walk_weight"]
	while walker.percent_opened() < initial_open_p:
		walker.goto_random_opened()
		walker.remember()
		if walker.rng.randf() < initial_goto_edge_p:
			walker.goto_random_edge()
		else:
			walker.goto_random_closed()
		while walker.is_on_closed():
			walker.step_weighted_last_remembered(initial_random_walk_weight)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.FLOOR))
		walker.commit()
		walker.forget()

	# Carves more of an open center, but leaving variance by spawning a bunch in a radius
	var secondary_open_p: float = LEVEL_SETTINGS[level]["secondary_open_p"]
	var secondary_open_radius: float = LEVEL_SETTINGS[level]["secondary_open_radius"]
	var secondary_random_walk_weight: float = LEVEL_SETTINGS[level]["secondary_random_walk_weight"]
	var tries := 100
	while walker.percent_opened() < secondary_open_p and tries > 0:
		tries -= 1
		var start := center + (Vector2.LEFT.rotated(walker.rng.randf() * TAU) * secondary_open_radius).floor()
		walker.goto(start.x, start.y)
		walker.remember()
		walker.gotov(center)
		while not walker.is_on_last_remembered():
			walker.step_weighted_last_remembered(secondary_random_walk_weight)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.FLOOR))
		walker.commit()
		walker.forget()

	yield()
	# Rocks

	for i in LEVEL_SETTINGS[level]["rock_count"]:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.ROCK))
		walker.commit()

	yield()
	# Pitfalls

	for i in LEVEL_SETTINGS[level]["pitfall_count"]:
		walker.goto_random_opened()
		for s in LEVEL_SETTINGS[level]["pitfall_size"]:
			walker.step_random()
			walker.mark(tile_to_walker_tile(Tile.PITFALL))
		walker.commit()

	yield()
	# Stalagmites

	for i in LEVEL_SETTINGS[level]["stalagmite_count"]:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.STALAGMITE))
		walker.commit()

	yield()
	# Gold comes before lava because we want lava to be a specific obstacle.

	var small_piles: int = LEVEL_SETTINGS[level]["small_gold_pile_count"]
	var large_piles: int = LEVEL_SETTINGS[level]["large_gold_pile_count"]
	while true:
		walker.goto_random_opened()
		var size: int
		if small_piles > 0:
			small_piles -= 1
			size = LEVEL_SETTINGS[level]["small_gold_pile_size"]
		elif large_piles > 0:
			large_piles -= 1
			size = LEVEL_SETTINGS[level]["large_gold_pile_size"]
		else:
			break
		for s in size:
			walker.step_random()
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.GOLD_PILE))
		walker.commit(Walker.COMMIT_OPENED_OVER_OPENED)

	yield()
	# Lava pools.

	var small_pools: int = LEVEL_SETTINGS[level]["small_lava_pool_count"]
	var small_pool_size: int = LEVEL_SETTINGS[level]["small_lava_pool_size"]
	var large_pools: int = LEVEL_SETTINGS[level]["large_lava_pool_count"]
	var large_pool_size: int = LEVEL_SETTINGS[level]["large_lava_pool_size"]
	while true:
		walker.goto_random_opened()
		var size: int
		if small_pools > 0:
			small_pools -= 1
			size = small_pool_size
		elif large_pools > 0:
			large_pools -= 1
			size = large_pool_size
		else:
			break
		for s in size:
			walker.step_random()
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.LAVA_CARVING))
		walker.commit()

	yield()
	# Lava Rivers

	var circle := PointSets.circle(4)

	walker.goto_random_edge()
	walker.remember()
	for i in LEVEL_SETTINGS[level]["lava_river_count"]:
		walker.goto_random_edge()
		while not walker.is_on_last_remembered():
			walker.step_weighted_last_remembered(0.6)
			walker.mark_point_set(circle, tile_to_walker_tile(Tile.FLOOR))
			walker.commit(Walker.COMMIT_OPENED_OVER_CLOSED)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.LAVA_CARVING))
			walker.commit()
	walker.forget()

	# Save lava info.
	var lava_tiles := PointSets.copy(walker.pinned_tiles[tile_to_walker_tile(Tile.LAVA_CARVING)])

	yield()
	# Treasure Chests
	var treasures: int = LEVEL_SETTINGS[level]["treasure_chest_count"]
	for i in treasures:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.TREASURE_CHEST))
		walker.commit()

	yield()
	# Entities

	var to_add := []

	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			if navigation_system.is_edge(x, y):
				tile_system.set_tile(x, y, Tile.WALL)
			else:
				var tile := walker_tile_to_tile(walker.get_tile(x - 1, y - 1))
				if tile >= Tile.CHASM and tile <= Tile.ABYSS_FLOOR:
					# Regular tiles.
					tile_system.set_tile(x, y, tile)
				else:
					var ent: Entity
					if tile == Tile.ROCK:
						tile_system.set_tile(x, y, Tile.FLOOR)
						ent = Entities.ROCK.instance()
					elif tile == Tile.GOLD_PILE:
						tile_system.set_tile(x, y, Tile.FLOOR)
						ent = Entities.GOLD_PILE.instance()
					elif tile == Tile.TREASURE_CHEST:
						tile_system.set_tile(x, y, Tile.FLOOR)
						ent = Entities.TREASURE_CHEST.instance()
					elif tile == Tile.STALAGMITE:
						tile_system.set_tile(x, y, Tile.FLOOR)
						ent = Entities.STALAGMITE.instance()
					elif tile == Tile.PITFALL:
						tile_system.set_tile(x, y, Tile.FLOOR)
						ent = Entities.PITFALL.instance()
					elif tile == Tile.LAVA_CARVING:
						# Abyss blocks light, optimizes lava casts.
						tile_system.set_tile(x, y, Tile.ABYSS_WALL)
						# Set lava to a closed variant, so we have accurate map info.
						walker.goto(x - 1, y - 1)
						walker.mark(tile_to_walker_tile(Tile.LAVA_SETTLED))
						ent = Entities.LAVA.instance()
					ent.grid_position = Vector2(x, y)
					to_add.append(ent)
	walker.commit()

	var dragonling_count: int = LEVEL_SETTINGS[level]["dragonling_count"]
	var magma_slug_count: int = LEVEL_SETTINGS[level]["magma_slug_count"]
	var golem_count: int = LEVEL_SETTINGS[level]["golem_count"]
	var tornado_count: int = LEVEL_SETTINGS[level]["tornado_count"]
	while true:
		var pos := walker.opened_tiles.random(walker.rng) + Vector2(1, 1)
		var ent: Entity
		if dragonling_count > 0:
			ent = Entities.DRAGONLING.instance()
			dragonling_count -= 1
		elif magma_slug_count > 0:
			pos = lava_tiles.random(walker.rng) + Vector2(1, 1)
			ent = Entities.MAGMA_SLUG.instance()
			magma_slug_count -= 1
		elif golem_count > 0:
			ent = Entities.GOLEM.instance()
			golem_count -= 1
		elif tornado_count > 0:
			ent = Entities.TORNADO.instance()
			tornado_count -= 1
		else:
			break
		ent.grid_position = Vector2(pos.x, pos.y)
		to_add.append(ent)

	yield()
	# Player and exits.

	var player_spawn := walker.exit_tiles.random(walker.rng) + Vector2(1, 1)
	entity_system.player.grid_position = player_spawn
	# XXX: Kinda hacky.  Should be handled by "move", but we don't want to trigger components.
	entity_system.update_entity(entity_system.player)

	var farthest_exit := player_spawn
	var farthest_amount2 := 0
	for exit in walker.exit_tiles.array:
		var exit_dist: float = exit.distance_squared_to(player_spawn)
		if exit_dist > farthest_amount2:
			farthest_exit = exit
			farthest_amount2 = exit_dist

	for p in circle.array:
		var pd: Vector2 = p + farthest_exit
		if navigation_system.is_edge(pd.x, pd.y):
			tile_system.set_tile(pd.x, pd.y, Tile.EXIT)

	yield()
	# Make lava come from somewhere.
	for x in 2:
		for y in Constants.MAP_ROWS - 3:
			var check := Vector2(x * (Constants.MAP_COLUMNS - 3), y + 1)
			if walker.get_tile(check.x, check.y) == tile_to_walker_tile(Tile.LAVA_SETTLED):
				var realv := Vector2(x * (Constants.MAP_COLUMNS - 1), y + 1)
				tile_system.set_tile(realv.x, realv.y, Tile.FLOOR)
				var ent: Entity = Entities.LAVA.instance()
				ent.grid_position = realv
				to_add.append(ent)
	for x in Constants.MAP_COLUMNS - 3:
		for y in 2:
			var check := Vector2(x + 1, y * (Constants.MAP_ROWS - 3))
			if walker.get_tile(check.x, check.y) == tile_to_walker_tile(Tile.LAVA_SETTLED):
				var realv := Vector2(x + 1, y * (Constants.MAP_ROWS - 1))
				tile_system.set_tile(realv.x, realv.y, Tile.FLOOR)
				var ent: Entity = Entities.LAVA.instance()
				ent.grid_position = realv
				to_add.append(ent)

	yield()
	# Light.

	bright_system.update_blocking_grid()
	yield()
	for ent in to_add:
		entity_system.add_entity(ent)
	yield()
	bright_system.update_brights()
	yield()
	bright_system.update_tiles()
	yield()

	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			var tile := tile_system.get_tile(x, y)
			if tile == Tile.ABYSS_WALL:
				tile_system.set_tile(x, y, Tile.FLOOR)

	yield()
	bright_system.update_blocking_grid()

	generated_level = level
	emit_signal("entered_level", level)

func tile_to_walker_tile(tile: int) -> int:
	return tile - Tile.WALL

func walker_tile_to_tile(tile: int) -> int:
	return tile + Tile.WALL
