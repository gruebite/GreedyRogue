extends Component
class_name Defender

const NAME := "Defender"

signal attacked(by)

func attack(by: Entity) -> void:
	emit_signal("attacked", by)
