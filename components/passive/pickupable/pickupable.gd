extends Component
class_name Pickupable

const NAME := "Pickupable"

signal picked_up(by)

func pickup(by) -> void:
	emit_signal("picked_up", by)
