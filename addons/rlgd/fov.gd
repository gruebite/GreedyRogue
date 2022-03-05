extends Reference
class_name Fov

## Anything <= 0 is blocking, anything > 0 is unblocking.
enum Transparency {
	NONE,
	FULL,
}

## Anything <= 0 is unlit, anything > 0 is lit.
enum Lighting {
	NONE,
	FULL,
}
