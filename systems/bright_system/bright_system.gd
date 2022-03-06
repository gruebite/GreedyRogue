extends Node2D
class_name BrightSystem

const GROUP_NAME := "bright_system"

onready var turn_system: TurnSystem = get_node("../TurnSystem")
onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")

var blocking_grid := DenseGrid.new(Constants.MAP_COLUMNS, Constants.MAP_ROWS)
# Static light grid, can only add to this, not take away.  For lava.
var static_light_grid := DenseGrid.new(Constants.MAP_COLUMNS, Constants.MAP_ROWS)
# Dynamic light grid.
var dynamic_light_grid := DenseGrid.new(Constants.MAP_COLUMNS, Constants.MAP_ROWS)
# Bright -> true
var brights := {}

var _scratch_grid := SparseGrid.new()

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)
	var _ignore = turn_system.connect("out_of_turn", self, "update_brights")

func get_brightness(x: int, y: int) -> int:
	var s = static_light_grid.get_cell(x, y)
	if s == null:
		s = 0
	var d = dynamic_light_grid.get_cell(x, y)
	if d == null:
		d = 0
	return s if s > d else d

# Casts static light.
func cast_light(x: int, y: int, lit_radius: int, dim_radius: int) -> void:
	var origin := Vector2(x, y)
	var lit_radius2 := lit_radius * lit_radius
	ShadowCast.compute(blocking_grid, _scratch_grid, origin, dim_radius)
	for cell in _scratch_grid.cells:
		var offset: Vector2 = cell - origin
		if offset.length_squared() <= lit_radius2:
			static_light_grid.set_cellv(cell, Brightness.LIT)
		else:
			static_light_grid.set_cellv(cell, Brightness.DIM)
	_scratch_grid.clear()

# Dynamic
func add_bright(bright: Node2D) -> void:
	brights[bright] = true

func remove_bright(bright: Node2D) -> void:
	var _ignore = brights.erase(bright)

func update_brights() -> void:
	dynamic_light_grid.clear()
	
	for b in brights:
		print(b)
		var origin: Vector2 = b.entity.grid_position
		var lit_radius2: int = b.lit_radius * b.lit_radius
		ShadowCast.compute(blocking_grid, _scratch_grid, origin, b.dim_radius)
		for cell in _scratch_grid.cells:
			var offset: Vector2 = cell - origin
			if offset.length_squared() <= lit_radius2:
				dynamic_light_grid.set_cellv(cell, Brightness.LIT)
			else:
				dynamic_light_grid.set_cellv(cell, Brightness.DIM)
		_scratch_grid.clear()

	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			var brightness := get_brightness(x, y)
			tile_system.set_brightness(x, y, brightness)

func update_blocking_grid() -> void:
	blocking_grid.clear()
	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			var tile := tile_system.get_tile(x, y)
			var blocks_light: bool = Tile.LIST[tile][Tile.Property.BLOCKS_LIGHT]
			if blocks_light:
				blocking_grid.set_cell(x, y, Fov.Transparency.NONE)
			else:
				blocking_grid.set_cell(x, y, Fov.Transparency.FULL)

func _brightness_none() -> int:
	return Brightness.NONE
