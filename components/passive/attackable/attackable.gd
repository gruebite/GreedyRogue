extends Component
class_name Attackable

const NAME := "Attackable"

signal attacked(by)

export var immune := false
export var resistance := 0

func attack(by) -> void:
	if not immune:
		emit_signal("attacked", by)
