extends Component
class_name Flammable

const NAME := "Flammable"

signal burned(amount)

func burn(amount: int) -> void:
	emit_signal("burned", amount)
