extends Component
class_name Jumpable

const NAME := "Jumpable"

signal jumped(by)

func jump(by) -> void:
	emit_signal("jumped", by)
