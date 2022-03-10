extends Component
class_name Bumper

const NAME := "Bumper"

enum {
	PLAYER = 0x1,
	ENVIRONMENT = 0x2,
	OBJECTS = 0x4,
	DRAGONS = 0x8,
	ELEMENTALS = 0x10,
}

signal bumped(other)

export(int, FLAGS, "PLAYER", "ENVIRONMENT", "OBJECTS", "DRAGONS", "ELEMENTALS") var bump_mask = 0

func does_bump(bumpable: Bumpable) -> bool:
	if not bumpable:
		return false
	if bump_mask & bumpable.bump_mask != 0:
		return true
	return false

func do_bump(bumpable: Bumpable) -> void:
	emit_signal("bumped", bumpable.entity)
	bumpable.bump(entity)
