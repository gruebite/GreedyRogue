extends Component
class_name Trippable

const NAME := "Trippable"

signal tripped(by)

func trip(by) -> void:
	emit_signal("tripped", by)
