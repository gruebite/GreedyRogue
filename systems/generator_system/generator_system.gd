extends Node2D
class_name GeneratorSystem

const GROUP_NAME := "generator_system"

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")
onready var hoard_system: HoardSystem = get_node("../HoardSystem")
onready var bright_system: BrightSystem = get_node("../BrightSystem")
onready var navigation_system: NavigationSystem = get_node("../NavigationSystem")

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func generate() -> void:
	# Reset bright first because entity_system reset will add the player.
	bright_system.reset()
	entity_system.reset()
	hoard_system.reset()

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

	var plus := PointSets.plus()
	while walker.percent_opened() < 0.7:
		walker.goto_random_opened()
		walker.remember()
		if walker.rng.randf() < 0.5:
			walker.goto_random_edge()
		else:
			walker.goto_random_closed()
		while walker.is_on_closed():
			walker.step_weighted_last_remembered(0.6)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.FLOOR))
		walker.commit()
		walker.forget()
	var tries := 100
	while walker.percent_opened() < 0.8 and tries > 0:
		tries -= 1
		var start := center + (Vector2.LEFT.rotated(walker.rng.randf() * TAU) * 10).floor()
		walker.goto(start.x, start.y)
		walker.remember()
		walker.gotov(center)
		while not walker.is_on_last_remembered():
			walker.step_weighted_last_remembered(0.7)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.FLOOR))
		walker.commit()
		walker.forget()

	yield()
	# Rocks

	for i in 40:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.ROCK))
		walker.commit()

	yield()
	# Pits

	for i in 10:
		walker.goto_random_opened()
		for s in 10:
			walker.step_random()
			walker.mark(tile_to_walker_tile(Tile.PITFALL))
		walker.commit()

	yield()
	# Stalagmites

	for i in 20:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.STALAGMITE))
		walker.commit()

	yield()
	# Lava pools.

	var pools := walker.rng.randi_range(1, 10)
	var small_pools := walker.rng.randi_range(pools / 2, pools)
	var large_pools := walker.rng.randi_range(0, pools - small_pools)
	for i in pools:
		walker.goto_random_opened()
		var size: int
		if small_pools > 0:
			small_pools -= 1
			size = 5
		elif large_pools > 0:
			large_pools -= 1
			size = 15
		for s in size:
			walker.step_random()
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.LAVA_CARVING))
		walker.commit()

	yield()
	# Lava Rivers

	var circle := PointSets.circle(4)

	walker.goto_random_edge()
	walker.remember()
	for i in 2:
		walker.goto_random_edge()
		while not walker.is_on_last_remembered():
			walker.step_weighted_last_remembered(0.6)
			walker.mark_point_set(circle, tile_to_walker_tile(Tile.FLOOR))
			walker.commit(Walker.COMMIT_OPENED_OVER_CLOSED)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.LAVA_CARVING))
			walker.commit()
	walker.forget()

	yield()
	# Gold

	var small_piles := 10
	var medium_piles := 3
	var large_piles := 1
	var piles := small_piles + medium_piles + large_piles
	for i in piles:
		walker.goto_random_opened()
		var size: int
		if small_piles > 0:
			small_piles -= 1
			size = 3
		elif medium_piles > 0:
			medium_piles -= 1
			size = 8
		elif large_piles > 0:
			large_piles -= 1
			size = 10
		for s in size:
			walker.step_random()
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.GOLD_PILE))
		walker.commit(Walker.COMMIT_OPENED_OVER_OPENED)

	yield()
	# Treasure Chests
	var treasures := 3
	for i in treasures:
		walker.goto_random_opened()
		walker.mark(tile_to_walker_tile(Tile.TREASURE_CHEST))
		walker.commit()

	yield()
	# Slugs

	var slugs := 10
	for i in slugs:
		walker.goto_random_pinned(tile_to_walker_tile(Tile.LAVA_CARVING))
		walker.mark(tile_to_walker_tile(Tile.SLUG))
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
					elif tile == Tile.SLUG:
						# Abyss blocks light, optimizes lava casts.
						tile_system.set_tile(x, y, Tile.ABYSS_WALL)
						# Set lava to a closed variant, so we have accurate map info.
						walker.goto(x - 1, y - 1)
						walker.mark(tile_to_walker_tile(Tile.LAVA_SETTLED))
						ent = Entities.LAVA.instance()
						ent.grid_position = Vector2(x, y)
						to_add.append(ent)
						ent = Entities.MAGMA_SLUG.instance()
					ent.grid_position = Vector2(x, y)
					to_add.append(ent)
	walker.commit()

	var dragon_count := 5
	var golem_count := 20
	var tornado_count := 1
	while true:
		var pos := walker.opened_tiles.random(walker.rng) + Vector2(1, 1)
		var ent: Entity
		if dragon_count > 0:
			ent = Entities.DRAGONLING.instance()
			dragon_count -= 1
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

func tile_to_walker_tile(tile: int) -> int:
	return tile - Tile.WALL

func walker_tile_to_tile(tile: int) -> int:
	return tile + Tile.WALL
