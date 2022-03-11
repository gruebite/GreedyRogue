extends Component
class_name Harmable

const NAME := "Harmable"

signal harmed(by)

export var immune := false
export var resistance := 0

func harm(by) -> void:
	if not immune:
		emit_signal("harmed", by)
