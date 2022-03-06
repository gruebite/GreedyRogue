extends Component
class_name Anxiety

const NAME := "Anxiety"

signal anxiety_changed(to, mx)

export var normal_panic := 1
export var max_anxiety := 200
var panic := 1
var anxiety := 0 setget set_anxiety

func _ready() -> void:
	var _ignore = entity.connect("moved", self, "_on_entity_moved")

func _on_entity_moved(_from: Vector2, _to: Vector2) -> void:
	self.anxiety += panic
	if anxiety > max_anxiety:
		queue_free()
	panic = normal_panic

func set_anxiety(to: int) -> void:
	if to < 0: to = 0
	if to > max_anxiety: to = max_anxiety
	anxiety = to
	emit_signal("anxiety_changed", to, max_anxiety)
