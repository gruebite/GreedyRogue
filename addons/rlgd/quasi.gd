extends Reference
class_name Quasi

## 
## Quasi random numbers
##

## Equidistance generator.
## Credit: http://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/
static func r2(index: float) -> Vector2:
	var x = 0.7548776662466927 * index
	var y = 0.5698402909980532 * index
	return Vector2(x - floor(x), y - floor(y))

## Estimates the closest or farthest distance
static func r2d(index: float, farthest: bool=false) -> float:
	if farthest:
		return 0.868 / sqrt(index)
	else:
		return 0.549 / sqrt(index)

static func r2c(d: float, farther: bool=false) -> float:
	if farther:
		return pow(0.868 / d, 2)
	else:
		return pow(0.549 / d, 2)

## 1-dimensional r2
static func r2_1(index: float) -> float:
	var g := 1.6180339887498948482
	var a1 := 1.0 / g
	return fmod(0.5 + a1 * index, 1)

## 3-dimensional r2
static func r2_3(index: float) -> Vector3:
	var g := 1.22074408460575947536
	var a1 := 1.0 / g
	var a2 := 1.0 / (g * g)
	var a3 := 1.0 / (g * g * g)
	return Vector3(
		fmod(0.5 + a1 * index, 1),
		fmod(0.5 + a2 * index, 1),
		fmod(0.5 + a3 * index, 1))
