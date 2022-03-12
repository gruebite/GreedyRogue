extends Component
class_name Slippable

const NAME := "Slippable"

signal slipped(by)

func slip(by) -> void:
	emit_signal("slipped", by)
