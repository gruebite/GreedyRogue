extends Node2D
class_name NavigationSystem

const GROUP_NAME := "navigation_system"

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func out_of_bounds(x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= Constants.MAP_COLUMNS or y >= Constants.MAP_ROWS

func is_edge(x: int, y: int) -> bool:
	return x == 0 or y == 0 or x == Constants.MAP_COLUMNS - 1 or y == Constants.MAP_ROWS - 1

## An entity can move into a place if:
## - Not out of bounds
## - The tile doesn't block movement
## - Entity is not a Bumper
## - There are no Bumpable entities we must bump (on same layer or flag), but can't
func can_move_to(ent: Entity, desired: Vector2) -> bool:
	# OOB.
	if out_of_bounds(desired.x, desired.y):
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
		var must_bump = bumpable.must_bump or bumpable.entity.layer == ent.layer
		# At least one is bumpable that we can't bump.
		if must_bump and (bumper.bump_mask & bumpable.bump_mask) == 0:
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
				bumper.bump(bumpable.entity)
				bumped += 1
			# If we couldn't bump, but had to, we will not move.
			elif bumpable.must_bump:
				bumped += 99
		# We bumped something.
		if bumped > 0:
			return

	ent.move(desired)
	entity_system.update_entity(ent)

func can_see(from: Entity, to: Entity, dist: int) -> bool:
	var fpos := from.grid_position
	var tpos := to.grid_position
	if fpos.distance_squared_to(tpos) >= dist * dist:
		return false
	var line := Pathing.line(fpos.x, fpos.y, tpos.x, tpos.y)
	for v in line:
		if tile_system.blocks_light(v.x, v.y):
			return false
	return true

func on_lava(x: int, y: int) -> bool:
	var yep := false
	for matter in entity_system.get_components(x, y, Matter.NAME):
		if Matter.LAVA & matter.mask:
			yep = true
			break
	return yep
