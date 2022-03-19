extends Node2D
class_name NavigationSystem

const GROUP_NAME := "navigation_system"

onready var tile_system: TileSystem = get_node("../TileSystem")
onready var entity_system: EntitySystem = get_node("../EntitySystem")

var astar: AStar = AStar.new()

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

func out_of_bounds(x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= Constants.MAP_COLUMNS or y >= Constants.MAP_ROWS

func is_edge(x: int, y: int) -> bool:
	return x == 0 or y == 0 or x == Constants.MAP_COLUMNS - 1 or y == Constants.MAP_ROWS - 1

func build_astar() -> void:
	astar.clear()
	# Build points.
	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			var id: int = y * Constants.MAP_COLUMNS + x
			astar.add_point(id, Vector3(x, y, 0))
	# Connect points.  This does some redundant work, but it's simple.
	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			if tile_system.blocks_movement(x, y):
				continue
			var id: int = y * Constants.MAP_COLUMNS + x
			for dir in Direction.CARDINALS:
				var dv := Direction.delta(dir)
				if tile_system.blocks_movement(x + dv.x, y + dv.y):
					continue
				var nid: int = (y + dv.y) * Constants.MAP_COLUMNS + (x + dv.x)
				astar.connect_points(id, nid)

func path_to(from: Vector2, to: Vector2) -> PoolIntArray:
	return astar.get_id_path(from.y * Constants.MAP_COLUMNS + from.x, to.y * Constants.MAP_COLUMNS + to.x)

func path_vector(id: int) -> Vector2:
	var v := astar.get_point_position(id)
	return Vector2(v.x, v.y)


## An entity can move into a place if:
## - Not out of bounds
## - If entity is a bumper:
## 	- There are entities to bump
##  - There are no entities that must be bumped (on same player), but can't
## - The tile doesn't block movement (checked last to allow in-wall bumps, if entity)
##
## Note: Capability to move to a position doesn't imply you'll end up there.
func can_move_to(ent: Entity, desired: Vector2, excluding = null) -> bool:
	# OOB.
	if out_of_bounds(desired.x, desired.y):
		return false

	var bumper: Bumper = ent.get_component(Bumper.NAME)
	if bumper:
		var entities := entity_system.get_entities(desired.x, desired.y)
		var can_bump := false
		for ent in entities:
			if excluding:
				for ex in excluding:
					if ent.get_component(ex):
						return false

			var bumpable: Bumpable = ent.get_component(Bumpable.NAME)
			if not bumpable: continue
			var must_bump = bumpable.must_bump or bumpable.entity.layer == ent.layer
			if bumper.does_bump(bumpable):
				can_bump = true
			elif must_bump:
				return false
		if can_bump:
			return true

	# Tile blocks movement?
	var tile := tile_system.get_tile(desired.x, desired.y)
	if Tile.LIST[tile][Tile.Property.BLOCKS_MOVEMENT]:
		return false
	return true

func move_to(ent: Entity, desired: Vector2) -> void:
	var bumper: Bumper = ent.get_component(Bumper.NAME)
	# If we bump, we try.
	if bumper:
		var bumpables := entity_system.get_components(desired.x, desired.y, Bumpable.NAME)
		var bumped := 0
		for bumpable in bumpables:
			var must_bump = bumpable.must_bump or bumpable.entity.layer == ent.layer
			if bumper.does_bump(bumpable):
				bumper.do_bump(bumpable)
				bumped += 1
			# If we couldn't bump, but had to, we will not move.
			elif must_bump:
				bumped += 99
		# We bumped something.
		if bumped > 0:
			return

	ent.move(desired)

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

func is_lava(x: int, y: int) -> bool:
	if out_of_bounds(x, y):
		return false
	return entity_system.get_components(x, y, Molten.NAME).size() > 0

func is_near_lava(x: int, y: int) -> bool:
	for dir in Direction.COMPASS:
		var dv := Direction.delta(dir)
		var gpos: Vector2 = Vector2(x, y) + dv
		if is_lava(gpos.x, gpos.y):
			return true
	return false

# Should be able to do this smarter with the generation info.
func find_random_unblocked() -> Vector2:
	var tries := 50
	while tries > 0:
		var gpos := Vector2(randi() % Constants.MAP_COLUMNS, randi() % Constants.MAP_ROWS)
		if not tile_system.blocks_movement(gpos.x, gpos.y):
			return gpos
		tries -= 1
	# Default to center.
	return Constants.MAP_SIZE / 2

func cardinal_to(from: Vector2, to: Vector2) -> int:
	var vec := to - from
	vec.x = sign(vec.x)
	vec.y = sign(vec.y)
	if vec.x != 0 and vec.y != 0:
		if randi() % 2 == 0:
			vec.x = 0
		else:
			vec.y = 0
	if vec.x == 1:
		return Direction.EAST
	elif vec.y == 1:
		return Direction.SOUTH
	elif vec.x == -1:
		return Direction.WEST
	elif vec.y == -1:
		return Direction.NORTH
	else:
		return -1
