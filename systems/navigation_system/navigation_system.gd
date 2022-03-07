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

func is_exit(x: int, y: int) -> bool:
	return x == 0 or y == 0 or x == Constants.MAP_COLUMNS - 1 or y == Constants.MAP_ROWS - 1

## An entity can move into a place if:
## - Not out of bounds
## - The tile doesn't block movement
## - Entity is not a Bumper
## - There are no Bumpable entities we must bump, but can't
func can_move_to(ent: Entity, desired: Vector2) -> bool:
	# OOB.
	if out_of_bounds(desired):
		return false

	# Tile blocks movement?
	var tile := tile_system.get_tile(desired.x, desired.y)
	if Tile.LIST[tile][Tile.Property.BLOCKS_MOVEMENT]:
		return false

	# We don't bump.
	var bumper: Bumper = ent.get_component(Bumper.NAME)
	if not bumper:
		return true

	# Check bumpables.
	var bumpables := entity_system.get_components(desired.x, desired.y, Bumpable.NAME)
	for bumpable in bumpables:
		# At least one is bumpable that we can't bump.
		if bumpable.must_bump and (bumper.bump_mask & bumpable.bump_mask) == 0:
			return false
	return true

func move_to(ent: Entity, desired: Vector2) -> void:
	var bumper: Bumper = ent.get_component(Bumper.NAME)
	# If we bump, we try.
	if bumper:
		var bumpables := entity_system.get_components(desired.x, desired.y, Bumpable.NAME)
		var bumped := 0
		for bumpable in bumpables:
			if (bumper.bump_mask & bumpable.bump_mask) != 0:
				bumpable.bump(ent)
				bumped += 1
			# If we couldn't bump, but had to, we will not move.
			elif bumpable.must_bump:
				bumped += 99
		# We bumped something.
		if bumped > 0:
			return

	ent.move(desired)
	entity_system.update_entity(ent)
