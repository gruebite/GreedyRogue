extends Reference
class_name Hex

enum Orientation {
	#POINTY         FLAT
	ODD_R, EVEN_R, ODD_Q, EVEN_Q
}

class Layout:
	extends Reference
	
	const POINTY := [
		sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
		sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
		0.5
	]
	
	const FLAT := [
		3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
		2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
		0.0
	]
	
	static func from_orientation(orient: int) -> Array:
		if orient - 2 < 0:
			return POINTY
		else:
			return FLAT
	
	static func is_row_offset(v: Vector2, orient: int) -> bool:
		if orient == Orientation.ODD_R:
			return (int(v.y) & 1) == 1
		elif orient == Orientation.EVEN_R:
			return (int(v.y) & 1) == 0
		return false
	
	static func is_col_offset(v: Vector2, orient: int) -> bool:
		if orient == Orientation.ODD_Q:
			return (int(v.x) & 1) == 1
		elif orient == Orientation.EVEN_Q:
			return (int(v.x) & 1) == 0
		return false
	
	static func hex_to_pixel(coord: Vector2, orient: int=0, origin: Vector2=Vector2(), size: Vector2=Vector2(1, 1)) -> Vector2:
		var o := from_orientation(orient)
		var x: float = (o[0] * coord.x + o[1] * coord.y) * size.x
		var y: float = (o[2] * coord.x + o[3] * coord.y) * size.y
		return Vector2(x, y) + origin
		
	static func pixel_to_hex(v: Vector2, orient: int=0, origin: Vector2=Vector2(), size: Vector2=Vector2(1, 1)) -> Vector2:
		var o := from_orientation(orient)
		var u := Vector2(
			(v.x - origin.x) / size.x,
			(v.y - origin.y) / size.y
		)
		var q: float = o[4] * u.x + o[5] * u.y
		var r: float = o[6] * u.x + o[7] * u.y
		return Vector2(q, r)
		
	static func hex_to_pixel_grid(coord: Vector2, orient: int=0, origin: Vector2=Vector2(), size: Vector2=Vector2(1, 1)) -> Vector2:
		var offset := Coord.to_offset(coord, orient)
		var delta := Vector2()
		if is_row_offset(offset, orient):
			delta.x = size.x / 2
		elif is_col_offset(offset, orient):
			delta.y = size.y / 2
		return offset * size + origin + delta
		
	static func pixel_to_hex_grid(v: Vector2, orient: int=0, origin: Vector2=Vector2(), size: Vector2=Vector2(1, 1)) -> Vector2:
		var o := from_orientation(orient)
		var u := Vector2(
			(v.x - origin.x) / (size.x / o[0]),
			(v.y - origin.y) / (size.y / o[3])
		)
		var q: float = o[4] * u.x + o[5] * u.y
		var r: float = o[6] * u.x + o[7] * u.y
		return Coord.cround(Vector3(q, r, -q - r))
		
enum DirectionPointy {
	E, NE, NW, W, SW, SE,
}

enum DirectionFlat {
	SE, NE, N, NW, SW, S,
}

enum DiagonalPointy {
	ENE, NENW, NWW, WSW, SWSE, SEE,
}

enum DiagonalFlat {
	SENE, NEN, NNW, NWSW, SWS, SSW,
}

class Coord:
	extends Reference
	const ORIGIN := Vector2(0, 0)
	# Pointy: East, NorthEast, NorthWest, West, SouthWest, SouthEast
	# Flat: SouthEast, NorthEast, North, NorthWest, SouthWest, South
	const DIRECTIONS := [
		Vector2( 1,  0), Vector2( 1, -1), Vector2( 0, -1),
		Vector2(-1,  0), Vector2(-1,  1), Vector2( 0,  1),
	]
	# Pointy: ENE, NENW, NWW, WSW, SWSE, SEE
	# Flat: SENE, NEN, NNW, NWSW, SWS, SSW,
	const DIAGONALS := [
		Vector2( 2, -1), Vector2( 1, -2), Vector2(-1, -1),
		Vector2(-2,  1), Vector2(-1,  2), Vector2( 1,  1),
	]

	static func q(v: Vector2) -> int:
		return int(v.x)
	static func r(v: Vector2) -> int:
		return int(v.y)
	static func s(v: Vector2) -> int:
		return int(-v.x - v.y)

	static func direction(dir: int):
		return DIRECTIONS[dir]

	static func diagonal(dir: int):
		return DIAGONALS[dir]

	static func color(v: Vector2) -> int:
		var m := int((-v.x - v.y) - v.y)
		if m < 0:
			return int(abs((m % 3) + m)) % 3
		else:
			return int(abs(m % 3))
			
	static func to_offset(v: Vector2, orient: int=0) -> Vector2:
		match orient:
			Orientation.ODD_R: return to_oddr(v)
			Orientation.EVEN_R: return to_evenr(v)
			Orientation.ODD_Q: return to_oddq(v)
			Orientation.EVEN_Q: return to_evenq(v)
		return Vector2()
			
	static func to_oddr(v: Vector2) -> Vector2:
		var col := int(v.x + (v.y - (int(v.y) & 1)) / 2)
		var row := int(v.y)
		return Vector2(col, row)
			
	static func to_evenr(v: Vector2) -> Vector2:
		var col := int(v.x + (v.y + (int(v.y) & 1)) / 2)
		var row := int(v.y)
		return Vector2(col, row)

	static func to_oddq(v: Vector2) -> Vector2:
		var col := int(v.x)
		var row := int(v.y + (v.x - (int(v.x) & 1)) / 2)
		return Vector2(col, row)

	static func to_evenq(v: Vector2) -> Vector2:
		var col := int(v.x)
		var row := int(v.y + (v.x + (int(v.x) & 1)) / 2)
		return Vector2(col, row)
			
	static func from_offset(v: Vector2, orient: int=0) -> Vector2:
		match orient:
			Orientation.ODD_R: return from_oddr(v)
			Orientation.EVEN_R: return from_evenr(v)
			Orientation.ODD_Q: return from_oddq(v)
			Orientation.EVEN_Q: return from_evenq(v)
		return Vector2()

	static func from_oddr(v: Vector2) -> Vector2:
		var x := int(v.x - (v.y - (int(v.y) & 1)) / 2)
		var y := int(v.y)
		return Vector2(x, y)

	static func from_evenr(v: Vector2) -> Vector2:
		var x := int(v.x - (v.y + (int(v.y) & 1)) / 2)
		var y := int(v.y)
		return Vector2(x, y)

	static func from_oddq(v: Vector2) -> Vector2:
		var x := int(v.x)
		var y := int(v.y - (v.x - (int(v.x) & 1)) / 2)
		return Vector2(x, y)

	static func from_evenq(v: Vector2) -> Vector2:
		var x := int(v.x)
		var y := int(v.y - (v.x + (int(v.x) & 1)) / 2)
		return Vector2(x, y)

	static func length(v: Vector2) -> int:
		return int(abs(v.x) + abs(v.y) + abs(-v.x - v.y) / 2) 

	static func distance(v: Vector2, u: Vector2) -> int:
		return length(v - u)
		
	static func neighbor(v: Vector2, dir: int) -> Vector2:
		return v + DIRECTIONS[dir]

	static func is_neighbor(v: Vector2, u: Vector2) -> bool:
		for dir in range(6):
			if neighbor(v, dir) == u:
				return true
		return false

	static func reflectq(v: Vector2) -> Vector2:
		return Vector2(v.x, -v.x - v.y)
	static func reflectr(v: Vector2) -> Vector2:
		return Vector2(-v.x - v.y, v.y)
	static func reflects(v: Vector2) -> Vector2:
		return Vector2(v.y, v.x)

	static func rotate_cw(v: Vector2, n: int) -> Vector2:
		match n % 6:
			0: return v
			1: return Vector2(-v.y, -(-v.x - v.y))
			2: return Vector2(-v.x - v.y, v.x)
			3: return Vector2(-v.x, -v.y)
			4: return Vector2(v.y, -v.x - v.y)
			5: return Vector2(-(-v.x - v.y), -v.x)
		return Vector2()

	static func rotate_ccw(v: Vector2, n: int) -> Vector2:
		match n % 6:
			0: return v
			1: return Vector2(-(-v.x - v.y), -v.x)
			2: return Vector2(v.y, -v.x - v.y)
			3: return Vector2(-v.x, -v.y)
			4: return Vector2(-v.x - v.y, v.x)
			5: return Vector2(-v.y, -(-v.x - v.y))
		return Vector2()
		
	static func rotate(v: Vector2, n: int) -> Vector2:
		if n < 0:
			return rotate_cw(v, -n)
		else:
			return rotate_ccw(v, n)
			
	static func cround(v: Vector3) -> Vector2:
		var q := int(round(v.x))
		var r := int(round(v.y))
		var s := int(round(v.z))
		var q_diff: float = abs(q - v.x)
		var r_diff: float = abs(r - v.y)
		var s_diff: float = abs(s - v.z)
		if q_diff > r_diff and q_diff > s_diff:
			q = -r - s
		elif r_diff > s_diff:
			r = -q - s
		else:
			s = -q - r
		return Vector2(q, r)

	static func gen_line(v: Vector2, u: Vector2) -> Array:
		var coords := []
		var dist := distance(v, u)
		var vn := Vector3(v.x, v.y, -v.x - v.y) + Vector3(0.000001, 0.000001, 0.000001)
		var un := Vector3(u.x, u.y, -u.x - u.y) + Vector3(0.000001, 0.000001, 0.000001)
		var step: float = 1 / max(dist, 1)
		for i in range(dist + 1):
			coords.append(cround(vn.linear_interpolate(un, step * i)))
		return coords

class Pattern:
	extends Reference
	
class Parallelogram:
	extends Pattern
	var length: int
	var height: int
	
	var _q: int
	var _r: int

	func _init(length_, height_):
		length = length_
		height = height_

	func _iter_init(_arg):
		_q = 0
		_r = 0
		return _q < length && _r < height

	func _iter_next(_arg):
		_r += 1
		if _r >= height:
			_r = 0
			_q += 1
		return _q < length

	func _iter_get(_arg):
		return Vector2(_q, _r)
		
class Triangle:
	extends Pattern
	var length: int
	
	var _q: int
	var _r: int

	func _init(length_):
		length = length_

	func _iter_init(_arg):
		_q = 0
		_r = 0
		return _q < length && _r < length - _q

	func _iter_next(_arg):
		_r += 1
		if _r >= length - _q:
			_r = 0
			_q += 1
		return _q < length

	func _iter_get(_arg):
		return Vector2(_q, _r)

class Hexagon:
	extends Pattern
	var radius: int
	
	var _q: int
	var _r1: int
	var _r2: int

	func _init(radius_):
		radius = radius_

	func _iter_init(_arg):
		_q = -radius
		_r1 = int(max(-radius, -_q - radius))
		_r2 = int(min(radius, -_q + radius))
		return _q <= radius && _r1 <= _r2

	func _iter_next(_arg):
		_r1 += 1
		if _r1 > _r2:
			_q += 1
			_r1 = int(max(-radius, -_q - radius))
			_r2 = int(min(radius, -_q + radius))
		return _q <= radius

	func _iter_get(_arg):
		return Vector2(_q, _r1)

class Rectangle:
	extends Pattern
	var width: int
	var height: int
	var inset: bool
	
	var _r: int
	var _roffset: int
	var _q: int

	func _init(width_: int, height_: int, inset_: bool=false):
		width = width_
		height = height_
		inset = inset_

	func _iter_init(_arg):
		_r = 0
		_roffset = 0
		_q = 0
		return _r < height and _q < width - _roffset

	func _iter_next(_arg):
		_q += 1
		if _q >= width - _roffset:
			_r += 1
			if inset:
				_roffset = (_r + 1) >> 1
			else:
				_roffset = _r >> 1
			_q = -_roffset
		return _r < height and _q < width - _roffset

	func _iter_get(_arg):
		return Vector2(_q, _r)

class Ring:
	extends Pattern
	var radius: int
	
	var _i: int
	var _dir: int
	var _j: int
	var _iter: Vector2

	func _init(radius_):
		radius = radius_

	func _iter_init(_arg):
		_i = 0
		_dir = 2
		_j = 0
		_iter = Vector2.ZERO + Coord.DIRECTIONS[0] * radius
		return _j < radius

	func _iter_next(_arg):
		_j += 1
		if _j >= radius:
			_j = 0
			_i += 1
			_dir = (_i + 2) % 6
		if _i >= 6:
			return false
		_iter = Coord.neighbor(_iter, _dir)
		return true

	func _iter_get(_arg):
		return _iter
