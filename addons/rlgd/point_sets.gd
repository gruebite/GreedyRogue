extends Reference
class_name PointSets

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

static func circle(radius: int) -> PointSet:
	var ps := PointSet.new()
	for x in radius * 2:
		for y in radius * 2:
			var dx: int = x - radius
			var dy: int = y - radius
			if dx * dx + dy * dy >= radius * radius:
				continue
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


