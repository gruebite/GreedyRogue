extends Component
class_name Flammable

const NAME := "Flammable"

signal burned(by)

var immune := false

func burn(by) -> void:
	if not immune:
		emit_signal("burned", by)
