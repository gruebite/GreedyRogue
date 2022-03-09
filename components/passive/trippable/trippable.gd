extends Component
class_name Trippable

const NAME := "Trippable"

signal tripped(by)

func trip(by: Entity) -> void:
	emit_signal("tripped", by)
