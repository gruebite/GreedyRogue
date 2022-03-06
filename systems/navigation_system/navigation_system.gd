extends Node2D
class_name NavigationSystem

const GROUP_NAME := "navigation_system"

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func out_of_bounds(gpos: Vector2) -> bool:
	return gpos.x < 0 or gpos.y < 0 or gpos.x >= Constants.MAP_COLUMNS or gpos.y >= Constants.MAP_ROWS

func can_move_to(gpos: Vector2) -> bool:
	if out_of_bounds(gpos):
		return false
	var tile := tile_system.get_tile(gpos.x, gpos.y)
	if Tile.LIST[tile][Tile.Property.BLOCKS_MOVEMENT]:
		return false
	
	var presence := entity_system.get_components(gpos.x, gpos.y, Presence.NAME)
	for p in presence:
		if p.blocks_movement:
			return false
	return true
