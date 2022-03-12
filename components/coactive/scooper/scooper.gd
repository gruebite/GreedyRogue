extends Component
class_name Scooper

const NAME := "Scooper"

signal scooped(other)

func scoop(other: Scoopable) -> void:
	emit_signal("scooped", other)
	other.scoop(self)
	other.entity.kill("being scooped")
