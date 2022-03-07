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

func bump(other: Entity) -> void:
	emit_signal("bumped", other)
