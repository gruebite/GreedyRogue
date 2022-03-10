extends Component
class_name Harmable

const NAME := "Harmable"

signal harmed(by)

export var immune := false

func harm(by: Entity) -> void:
	if not immune:
		emit_signal("harmed", by)
