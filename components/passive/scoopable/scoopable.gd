extends Component
class_name Scoopable

const NAME := "Scoopable"

signal scooped(by)

func scoop(by) -> void:
	emit_signal("scooped", by)
