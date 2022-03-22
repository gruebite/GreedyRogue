extends Component
class_name Anxiety

const NAME := "Anxiety"

signal mindful()
signal anxiety_changed(to, mx)
signal panicking(amount)
signal calmed_down()

export var normal_panic := 1
export var max_anxiety := 200 setget set_max_anxiety
var panic := 1
var anxiety := 0 setget set_anxiety
var anxiety_p: float setget , get_anxiety_p

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("taken_turns", self, "_on_taken_turns")

	emit_signal("anxiety_changed", anxiety, max_anxiety)

func _on_taken_turns() -> void:
	emit_signal("mindful")
	# Check if we panicked this turn.
	if panic > normal_panic:
		emit_signal("panicking", panic)
	else:
		emit_signal("calmed_down")
	self.anxiety += panic
	panic = normal_panic

func set_anxiety(to: int) -> void:
	if to < 0: to = 0
	if to > max_anxiety: to = max_anxiety
	anxiety = to
	if anxiety >= max_anxiety:
		entity.kill("anxiety")
	emit_signal("anxiety_changed", anxiety, max_anxiety)

func set_max_anxiety(to: int) -> void:
	if to < 0: to = 0
	max_anxiety = to
	if max_anxiety < anxiety:
		anxiety = max_anxiety
	if anxiety >= max_anxiety:
		entity.kill("anxiety")
	emit_signal("anxiety_changed", anxiety, max_anxiety)

func get_anxiety_p() -> float:
	return float(anxiety) / max_anxiety
