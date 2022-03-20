extends Node2D
class_name ColorTileMap

##
## Wraps a TileMap node with one that generates tiles with color variants.
##

export var texture: Texture
export var tile_size := Vector2(8, 8)
export var cell_size := Vector2(8, 8)
export(PoolColorArray) var colors = PoolColorArray()

onready var tile_map = $TileMap

var tile_count: int

func _ready() -> void:
	assert(texture != null)
	tile_count = int(texture.get_width() / tile_size.x) * int(texture.get_height() / tile_size.y)

	tile_map.cell_size = cell_size
	tile_map.cell_y_sort = true

	var tile_set = TileSet.new()

	var tile_id := 0
	for c in colors:
		var y := 0
		while y < texture.get_height():
			var x := 0
			while x < texture.get_width():
				tile_set.create_tile(tile_id)
				tile_set.tile_set_texture(tile_id, texture)
				tile_set.tile_set_region(tile_id, Rect2(x, y, tile_size.x, tile_size.y))
				tile_set.tile_set_modulate(tile_id, c)
				x += int(tile_size.x)
				tile_id += 1
			y += int(tile_size.y)

	tile_map.tile_set = tile_set
	pass

func set_tile(x: int, y: int, tile: int, color: int=0) -> void:
	tile_map.set_cell(x, y, tile + tile_count * color)

func clear_tile(x: int, y: int) -> void:
	tile_map.set_cell(x, y, -1)

func get_tile(x: int, y: int) -> int:
	return tile_map.get_cell(x, y) % tile_count

func get_color(x: int, y: int) -> int:
	var tile: int = tile_map.get_cell(x, y)
	if tile == -1:
		return -1
	return int(floor(tile / tile_count))

func clear() -> void:
	tile_map.clear()

func get_used_cells() -> Array: return tile_map.get_used_cells()
func get_used_cells_by_id(id: int) -> Array: return tile_map.get_used_cells_by_id(id)
func get_used_rect() -> Rect2: return tile_map.get_used_rect()

func map_to_world(map_position: Vector2) -> Vector2: return tile_map.map_to_world(map_position)
func world_to_map(world_position: Vector2) -> Vector2: return tile_map.world_to_map(world_position)
