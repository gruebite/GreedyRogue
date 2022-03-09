extends Component
class_name Defender

const NAME := "Defender"

signal attacked(by)

export var armor := 0

func attack(by: Entity) -> void:
	emit_signal("attacked", by)
