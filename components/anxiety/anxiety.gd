extends Component
class_name Anxiety

const NAME := "Anxiety"

signal anxiety_changed(to, mx)

export var normal_panic := 1
export var max_anxiety := 200
var panic := 1
var anxiety := 0 setget set_anxiety

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("in_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	self.anxiety += panic
	panic = normal_panic

func set_anxiety(to: int) -> void:
	if to < 0: to = 0
	if to > max_anxiety: to = max_anxiety
	anxiety = to
	if anxiety >= max_anxiety:
		entity.queue_free()
	emit_signal("anxiety_changed", anxiety, max_anxiety)
