extends Component
class_name Lifetime

const NAME := "Lifetime"

export var time := 1

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("initiated_turn", self, "_on_initiated_turn")
	if time <= 0:
		entity.kill("time")

func _on_initiated_turn() -> void:
	if time <= 0:
		entity.kill("time")
	time -= 1
