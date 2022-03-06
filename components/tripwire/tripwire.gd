extends Component
class_name Tripwire

const NAME := "Tripwire"

signal tripped(by)

func trip(by: Entity) -> void:
	emit_signal("tripped", by)
