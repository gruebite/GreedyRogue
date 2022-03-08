extends Component
class_name Backpack

const NAME := "Backpack"

signal gold_changed(to)
signal gained_item(item)

export var gold := 0 setget set_gold
export var items := []

func set_gold(to: int) -> void:
	gold = to
	emit_signal("gold_changed", to)
