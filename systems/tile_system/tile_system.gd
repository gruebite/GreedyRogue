extends Node2D
class_name TileSystem

const GROUP_NAME := "map_system"

var lit_background: int = Palette.BROWN_1
var dim_background: int = Palette.BROWN_0

onready var background: ColorTileMap = $Background
onready var foreground: TileMap = $Foreground

var tiles := {}

func _enter_tree() -> void:
	$Background.colors = Palette.LIST

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func is_exit(x: int, y: int) -> bool:
	return x == 0 or y == 0 or x == Constants.MAP_COLUMNS - 1 or y == Constants.MAP_ROWS - 1

func set_tile_bright(x: int, y: int, tile: int, brightness: int) -> void:
	tiles[Vector2(x, y)] = tile
	match brightness:
		Brightness.NONE:
			background.clear_tile(x, y)
			foreground.set_cell(x, y, -1)
		Brightness.DIM:
			background.set_tile(x, y, 0, dim_background)
			foreground.set_cell(x, y, tile * 2)
		Brightness.LIT:
			background.set_tile(x, y, 0, lit_background)
			foreground.set_cell(x, y, tile * 2 + 1)

func set_tile(x: int, y: int, tile: int) -> void:
	set_tile_bright(x, y, tile, get_brightness(x, y))

func get_tile(x: int, y: int) -> int:
	return tiles[Vector2(x, y)]

func set_brightness(x: int, y: int, brightness: int) -> void:
	set_tile_bright(x, y, get_tile(x, y), brightness)

func get_brightness(x: int, y: int) -> int:
	var c: int = foreground.get_cell(x, y)
	if c == -1:
		return Brightness.NONE
	else:
		return (c & 1) + 1
