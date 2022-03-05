extends Resource
class_name Walker

## Anything <= 0 is considered closed, unwalkable.  Anything > 0 is consider opened, walkable.
enum Tile {
	CLOSED,
	OPENED,
}

# Flags for overwriting when commiting marks.
enum {
	COMMIT_NONE = 0,
	COMMIT_OPENED_OVER_OPENED = 0x1,
	COMMIT_OPENED_OVER_CLOSED = 0x2,
	COMMIT_CLOSED_OVER_OPENED = 0x4,
	COMMIT_CLOSED_OVER_CLOSED = 0x8,
	COMMIT_OVER_OPENED = COMMIT_OPENED_OVER_OPENED | COMMIT_CLOSED_OVER_OPENED,
	COMMIT_OVER_CLOSED = COMMIT_OPENED_OVER_CLOSED | COMMIT_CLOSED_OVER_CLOSED,
	COMMIT_OVER_ALL = COMMIT_OVER_OPENED | COMMIT_OVER_CLOSED,
}

# Modes for checking marks.
enum {
	CHECK_MARKED = 0x1,
	CHECK_OPENED_BELOW = 0x2,
	CHECK_OPENED_DIAGONAL = 0x4,
	CHECK_OPENED_CARDINAL = 0x8,
	CHECK_CLOSED_BELOW = 0x10,
	CHECK_CLOSED_DIAGONAL = 0x20,
	CHECK_CLOSED_CARDINAL = 0x40,
	CHECK_OOB_BELOW = 0x80,
	CHECK_OOB_DIAGONAL = 0x100,
	CHECK_OOB_CARDINAL = 0x200,

	CHECK_OPENED_COMPASS = CHECK_OPENED_CARDINAL | CHECK_OPENED_DIAGONAL,
	CHECK_OPENED_ALL = CHECK_OPENED_COMPASS | CHECK_OPENED_BELOW,

	CHECK_OPENED_MARKED_BELOW = CHECK_OPENED_BELOW | CHECK_MARKED,
	CHECK_OPENED_MARKED_DIAGONAL = CHECK_OPENED_DIAGONAL | CHECK_MARKED,
	CHECK_OPENED_MARKED_CARDINAL = CHECK_OPENED_CARDINAL | CHECK_MARKED,
	CHECK_OPENED_MARKED_COMPASS = CHECK_OPENED_COMPASS | CHECK_MARKED,
	CHECK_OPENED_MARKED_ALL = CHECK_OPENED_ALL | CHECK_MARKED,

	CHECK_CLOSED_COMPASS = CHECK_CLOSED_CARDINAL | CHECK_CLOSED_DIAGONAL,
	CHECK_CLOSED_ALL = CHECK_CLOSED_COMPASS | CHECK_CLOSED_BELOW,

	CHECK_CLOSED_MARKED_BELOW = CHECK_CLOSED_BELOW | CHECK_MARKED,
	CHECK_CLOSED_MARKED_DIAGONAL = CHECK_CLOSED_DIAGONAL | CHECK_MARKED,
	CHECK_CLOSED_MARKED_CARDINAL = CHECK_CLOSED_CARDINAL | CHECK_MARKED,
	CHECK_CLOSED_MARKED_COMPASS = CHECK_CLOSED_COMPASS | CHECK_MARKED,
	CHECK_CLOSED_MARKED_ALL = CHECK_CLOSED_ALL | CHECK_MARKED,

	CHECK_OOB_COMPASS = CHECK_OOB_DIAGONAL | CHECK_OOB_CARDINAL,
	CHECK_OOB_ALL = CHECK_OOB_COMPASS | CHECK_OOB_BELOW,
}

var rng: RandomNumberGenerator
var opened_tiles := PointSet.new()
var closed_tiles := PointSet.new()
var pinned_tiles := {}

var grid := {}
var marked := {}

var remembered := []
var position := Vector2.ZERO
var width := -1
var height := -1

func _init(r: RandomNumberGenerator=null):
	if r:
		rng = r
	else:
		rng = RandomNumberGenerator.new()
		rng.randomize()

func start(w: int, h: int, tile: int=Tile.CLOSED) -> void:
	opened_tiles.clear()
	closed_tiles.clear()
	pinned_tiles.clear()
	grid.clear()
	remembered = []
	position = Vector2.ZERO
	width = w
	height = h
	for y in height:
		for x in width:
			if tile <= Tile.CLOSED:
				closed_tiles.add(x, y)
			else:
				opened_tiles.add(x, y)
			grid[Vector2(x, y)] = tile

func out_of_bounds(pos: Vector2) -> bool:
	return pos.x < 0 || pos.y < 0 || pos.x >= width || pos.y >= height

func percent_opened() -> float:
	return opened_tiles.length() / float(width * height)

func is_out_of_bounds() -> bool:
	return out_of_bounds(position)

func is_on_last_remembered() -> bool:
	return position == remembered[-1]

func is_on_opened(check_marked: bool=false) -> bool:
	if check_marked and marked.get(position, 0) > 0:
		return true
	return opened_tiles.hasv(position)

func is_on_closed(check_marked: bool=false) -> bool:
	if check_marked and marked.get(position, 1) <= Tile.CLOSED:
		return true
	return closed_tiles.hasv(position)

func is_on_tile(tile: int, check_marked: bool=false) -> bool:
	if check_marked:
		if marked.get(position) == tile:
			return true
	return grid.get(position) == tile

func pin(p: int) -> void:
	pinned_tiles[p] = PointSet.new()

func unpin(p: int) -> void:
	pinned_tiles.erase(p)

func remember() -> void:
	remembered.append(position)

func recall() -> void:
	position = remembered.pop_back()

func forget() -> void:
	remembered.pop_back()

func forget_all() -> void:
	remembered.clear()

func goto(x: int, y: int) -> void:
	position = Vector2(x, y)

func gotov(pos: Vector2) -> void:
	position = pos

func goto_random() -> void:
	position = Vector2(rng.randi_range(0, width - 1), rng.randi_range(0, height - 1))

func goto_random_opened() -> void:
	position = opened_tiles.random(rng)

func goto_random_closed() -> void:
	position = closed_tiles.random(rng)

func goto_random_pinned(p: int) -> void:
	assert(pinned_tiles.has(p), "could not find pin")
	position = pinned_tiles[p].random(rng)

func step(dx: int, dy: int) -> void:
	position += Vector2(dx, dy)

func stepv(delta: Vector2) -> void:
	position += delta

func step_random(dirs=Direction.COMPASS) -> void:
	position += Direction.delta(dirs[rng.randi_range(0, len(dirs) - 1)])

func step_weighted_tov(target: Vector2, weight: float, dirs=Direction.COMPASS) -> void:
	var target_angle := position.angle_to_point(target)
	var sum := 0.0
	var weights := []
	var candidates := []
	for dir in dirs:
		var delta := Direction.delta(dir)
		var cand = position + delta
		if out_of_bounds(cand):
			continue
		var cand_angle := position.angle_to_point(cand)
		weights.append(exp(weight * cos(cand_angle - target_angle)))
		candidates.append(cand)
		sum += weights[-1]
	var r := rng.randf() * sum
	for i in len(candidates):
		r -= weights[i]
		if r <= 0:
			position = candidates[i]
			break

func step_weighted_to(x: int, y: int, weight: float, dirs=Direction.COMPASS) -> void:
	step_weighted_tov(Vector2(x, y), weight, dirs)

func step_weighted_last_remembered(weight: float, dirs=Direction.COMPASS) -> void:
	step_weighted_tov(remembered[-1], weight, dirs)

func step_corridor_tov(target: Vector2, horizontal_first: bool) -> void:
	if target == position:
		return
	var deltav = target - position
	if horizontal_first:
		if deltav.x != 0:
			position += Vector2(sign(deltav.x), 0)
		else:
			position += Vector2(0, sign(deltav.y))
	else:
		if deltav.y != 0:
			position += Vector2(0, sign(deltav.y))
		else:
			position += Vector2(sign(deltav.x), 0)

func step_corridor_to(x: int, y: int, horizontal_first: bool) -> void:
	step_corridor_tov(Vector2(x, y), horizontal_first)

func step_corridor_last_remembered(horizontal_first: bool) -> void:
	step_corridor_tov(remembered[-1], horizontal_first)

func check(mode: int) -> bool:
	if mode & CHECK_OOB_BELOW and is_out_of_bounds():
		return false
	if mode & CHECK_OOB_DIAGONAL:
		for dir in Direction.DIAGONALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_out_of_bounds():
				recall()
				return false
			recall()
	if mode & CHECK_OOB_CARDINAL:
		for dir in Direction.CARDINALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_out_of_bounds():
				recall()
				return false
			recall()

	if mode & CHECK_OPENED_BELOW and is_on_opened(mode & CHECK_MARKED != 0):
		return false
	if mode & CHECK_OPENED_DIAGONAL:
		for dir in Direction.DIAGONALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_on_opened(mode & CHECK_MARKED != 0):
				recall()
				return false
			recall()
	if mode & CHECK_OPENED_CARDINAL:
		for dir in Direction.CARDINALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_on_opened(mode & CHECK_MARKED != 0):
				recall()
				return false
			recall()

	if mode & CHECK_CLOSED_BELOW and is_on_closed(mode & CHECK_MARKED != 0):
		return false
	if mode & CHECK_CLOSED_DIAGONAL:
		for dir in Direction.DIAGONALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_on_closed(mode & CHECK_MARKED != 0):
				recall()
				return false
			recall()
	if mode & CHECK_CLOSED_CARDINAL:
		for dir in Direction.CARDINALS:
			var delta := Direction.delta(dir)
			remember()
			stepv(delta)
			if is_on_closed(mode & CHECK_MARKED != 0):
				recall()
				return false
			recall()
	return true

func check_point_set(ps: PointSet, mode: int) -> bool:
	for v in ps.array:
		remember()
		step(v.x, v.y)
		if not check(mode):
			recall()
			return false
		recall()
	return true

func mark(tile: int=Tile.OPENED) -> void:
	marked[position] = tile

func mark_point_set(ps: PointSet, tile: int=Tile.OPENED) -> void:
	for v in ps.array:
		remember()
		stepv(v)
		mark(tile)
		recall()

func commit(commit_over: int=COMMIT_OVER_ALL) -> void:
	if commit_over != COMMIT_NONE:
		for pos in marked:
			var tile: int = marked[pos]
			var old_tile = grid.get(pos)
			if tile == old_tile:
				continue
			if tile >= Tile.OPENED:
				if (opened_tiles.hasv(pos) && commit_over & COMMIT_OPENED_OVER_OPENED) || \
				(closed_tiles.hasv(pos) && commit_over & COMMIT_OPENED_OVER_CLOSED):
					grid[pos] = tile
					closed_tiles.remove(pos.x, pos.y)
					opened_tiles.add(pos.x, pos.y)
			else:
				if (opened_tiles.hasv(pos) && commit_over & COMMIT_CLOSED_OVER_OPENED) || \
				(closed_tiles.hasv(pos) && commit_over & COMMIT_CLOSED_OVER_CLOSED):
					grid[pos] = tile
					opened_tiles.remove(pos.x, pos.y)
					closed_tiles.add(pos.x, pos.y)

			if old_tile != null and pinned_tiles.has(old_tile):
				pinned_tiles[old_tile].remove(pos.x, pos.y)
			if pinned_tiles.has(tile):
				pinned_tiles[tile].add(pos.x, pos.y)
	marked.clear()

func get_tile(x: int, y: int) -> int:
	return grid[Vector2(x, y)]

func get_tilev(v: Vector2) -> int:
	return grid[v]

func debug_print() -> void:
	for y in height:
		var line = ""
		for x in width:
			var c = grid[Vector2(x, y)]
			if c > 0:
				line += "#"
			else:
				line += " "
		print(line)
