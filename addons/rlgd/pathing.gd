extends Reference
class_name Pathing

##
## Generic path generating functions.
## 

static func line(x0: int, y0: int, x1: int, y1: int) -> Array:
	var pts := []
	var dx := int(abs(x1 - x0))
	var sx := 1 if x0 < x1 else -1
	var dy := int(abs(y1 - y0))
	var sy := 1 if y0 < y1 else - 1
	var err := int((dx if dx > dy else -dy) / 2)
	var e2: int
	while true:
		pts.append(Vector2(x0, y0))
		if x0 == x1 and y0 == y1: break
		e2 = err
		if e2 > -dx:
			err -= dy
			x0 += sx
		if e2 < dy:
			err += dx
			y0 += sy
	return pts
