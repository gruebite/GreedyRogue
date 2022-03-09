extends Component
class_name Anxiety

const NAME := "Anxiety"

signal anxiety_changed(to, mx)
signal panicking(amount)
signal calmed_down()

export var normal_panic := 1
export var max_anxiety := 200 setget set_max_anxiety
var panic := 1
var anxiety := 0 setget set_anxiety

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("in_turn", self, "_on_in_turn")

	emit_signal("anxiety_changed", anxiety, max_anxiety)

func _on_in_turn() -> void:
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
		entity.kill(self)
	emit_signal("anxiety_changed", anxiety, max_anxiety)

func set_max_anxiety(to: int) -> void:
	if to < 0: to = 0
	max_anxiety = to
	if max_anxiety < anxiety:
		anxiety = max_anxiety
	if anxiety >= max_anxiety:
		entity.kill(self)
	emit_signal("anxiety_changed", anxiety, max_anxiety)
