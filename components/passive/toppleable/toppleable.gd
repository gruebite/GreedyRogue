extends Component
class_name Toppleable

const NAME := "Toppleable"

signal toppled(by)

func topple(by: Entity) -> void:
	emit_signal("toppled", by)
