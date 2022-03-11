extends Component
class_name Bumpable

const NAME := "Bumpable"

signal bumped(by)

# If this can't be bumped (by a bumper), you can't pass.
export var must_bump := false
export(int, FLAGS, "PLAYER", "ENVIRONMENT", "OBJECTS", "DRAGONS", "ELEMENTALS") var bump_mask = 0

func bump(by) -> void:
	emit_signal("bumped", by)
