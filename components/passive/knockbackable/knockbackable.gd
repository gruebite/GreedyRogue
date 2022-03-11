extends Component
class_name Knockbackable

const NAME := "Knockbackable"

signal knocked_back(by)

export var immune := false

func knockback(by) -> void:
	if not immune:
		emit_signal("knocked_back", by)
