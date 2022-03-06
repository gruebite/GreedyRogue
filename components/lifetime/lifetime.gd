extends Component
class_name Lifetime

const NAME := "Lifetime"

export var time := 1

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore = turn_taker.connect("take_turn", self, "_on_take_turn")

func _on_take_turn() -> void:
	time -= 1
	if time <= 0:
		entity.queue_free()
