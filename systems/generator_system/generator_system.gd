extends Node2D
class_name GeneratorSystem

const GROUP_NAME := "generator_system"

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")
onready var bright_system: BrightSystem = get_node("../BrightSystem")

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func generate() -> void:
	var walker := Walker.new()
	walker.start(Constants.MAP_COLUMNS, Constants.MAP_ROWS)

	var circle := PointSets.ellipse(14, 8)

	walker.goto(Constants.MAP_COLUMNS / 2, Constants.MAP_ROWS / 2)
	walker.mark_point_set(circle, tile_to_walker_tile(Tile.FLOOR))
	walker.commit()

	var plus := PointSets.plus()
	while walker.percent_opened() < 0.6:
		walker.goto_random_opened()
		walker.remember()
		walker.goto_random_closed()
		while walker.is_on_closed():
			walker.step_weighted_last_remembered(0.7)
			walker.mark_point_set(plus, tile_to_walker_tile(Tile.FLOOR))
		walker.commit()
		walker.forget()

	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			var tile := walker_tile_to_tile(walker.get_tile(x, y))
			tile_system.set_tile(x, y, tile, Brightness.LIT)
	
	bright_system.update_blocking_grid()
	bright_system.update_brights()

func tile_to_walker_tile(tile: int) -> int:
	return tile - Tile.WALL

func walker_tile_to_tile(tile: int) -> int:
	return tile + Tile.WALL
