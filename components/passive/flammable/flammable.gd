extends Component
class_name Flammable

const NAME := "Flammable"

signal burned(by)

export var immune := false
export var resistance := 0

func burn(by) -> void:
	if not immune:
		emit_signal("burned", by)
