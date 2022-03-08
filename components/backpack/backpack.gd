extends Component
class_name Backpack

const NAME := "Backpack"

signal gold_changed(to)
signal gained_artifact(artifact)

export var gold := 0 setget set_gold

func set_gold(to: int) -> void:
	gold = to
	emit_signal("gold_changed", to)

func spawn_artifact(artifact) -> void:
	add_child(artifact)
	emit_signal("gained_artifact", artifact)
