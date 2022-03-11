extends Reference
class_name PointSets

static func copy(ps: PointSet) -> PointSet:
	return PointSet.new(ps.array.duplicate())

##
## Generator functions
##

static func plus() -> PointSet:
	var ps := PointSet.new()
	ps.add(0, 0)
	ps.add(-1, 0)
	ps.add(0, -1)
	ps.add(1, 0)
	ps.add(0, 1)
	return ps

static func circle(radius: int, inclusive: bool=true) -> PointSet:
	var ps := PointSet.new()
	var radius2: int = radius * radius - (0 if inclusive else 1)
	for x in radius * 2 + 1:
		for y in radius * 2 + 1:
			var dx: int = x - radius
			var dy: int = y - radius
			var d: int = dx * dx + dy * dy
			if d <= radius2:
				ps.add(dx, dy)
	return ps

static func ellipse(xradius: int, yradius: int) -> PointSet:
	var ps := PointSet.new()
	for x in xradius * 2:
		for y in yradius * 2:
			var dx: int = x - xradius
			var dy: int = y - yradius
			if dx * dx + dy * dy >= xradius * yradius:
				continue
			ps.add(dx, dy)
	return ps

static func square(radius: int) -> PointSet:
	var ps := PointSet.new()
	var dx: int = -radius
	while dx <= radius:
		var dy: int = -radius
		while dy <= radius:
			ps.add(dx, dy)
			dy += 1
		dx += 1
	return ps

static func rectangle(left: int, right: int, top: int, bottom: int) -> PointSet:
	var ps := PointSet.new()
	var dx: int = -left
	while dx <= right:
		var dy: int = -top
		while dy <= bottom:
			ps.add(dx, dy)
			dy += 1
		dx += 1
	return ps

## width is how quickly width grows with distance,
static func cone(dir: int, dist: int, width_ratio: float=1.0) -> PointSet:
	var ps := PointSet.new()
	var deltav := Direction.delta(dir)
	var leftv := Direction.delta(Direction.cardinal_left(dir))
	var rightv := Direction.delta(Direction.cardinal_right(dir))
	var linev := Vector2.ZERO
	for i in dist:
		ps.add(linev.x, linev.y)
		var width: int = int(i * width_ratio)
		for j in width:
			var lv: Vector2 = linev + leftv * (j + 1)
			ps.add(lv.x, lv.y)
			var rv: Vector2 = linev + rightv * (j + 1)
			ps.add(rv.x, rv.y)
		linev += deltav
	return ps

