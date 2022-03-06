extends Node2D
class_name TileSystem

const GROUP_NAME := "map_system"

var lit_background: int = Palette.BROWN_1
var dim_background: int = Palette.BROWN_0

onready var background: ColorTileMap = $Background
onready var foreground: TileMap = $Foreground

var tiles := {}

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

	background.colors = Palette.LIST

func set_tile(x: int, y: int, tile: int, brightness: int) -> void:
	tiles[Vector2(x, y)] = tile
	match brightness:
		Brightness.NONE:
			background.clear_tile(x, y)
			foreground.set_cell(x, y, -1)
		Brightness.LIT:
			background.set_tile(x, y, tile, lit_background)
			foreground.set_cell(x, y, tile * 2)
		Brightness.DIM:
			background.set_tile(x, y, tile, dim_background)
			foreground.set_cell(x, y, tile * 2 + 1)

func get_tile(x: int, y: int) -> int:
	return tiles[Vector2(x, y)]

func set_brightness(x: int, y: int, brightness: int) -> void:
	var tile := get_tile(x, y)
	set_tile(x, y, tile, brightness)
