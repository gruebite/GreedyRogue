extends Component
class_name Health

const NAME := "Health"

signal health_changed(to)

export var max_health := 10
var health := max_health setget set_health

func set_health(to: int) -> void:
	if to < 0: to = 0
	if to > max_health: to = max_health
	health = to
	if health == 0:
		queue_free()
	emit_signal("health_changed", health, max_health)
