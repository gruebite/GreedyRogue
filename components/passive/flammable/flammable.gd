extends Component
class_name Flammable

const NAME := "Flammable"

signal burned(amount)

var immune := false

func burn(amount: int) -> void:
	if not immune:
		emit_signal("burned", amount)
