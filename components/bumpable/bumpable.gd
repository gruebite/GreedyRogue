extends Component
class_name Bumpable

const NAME := "Bumpable"

signal bumped(by)

func bump(by: Entity) -> void:
	emit_signal("bumped", by)
