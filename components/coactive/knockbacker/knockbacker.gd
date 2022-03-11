extends Component
class_name Knockbacker

const NAME := "Knockbacker"

signal knocked_back(other)

export var on_bump := false
export var on_attack := false

func _ready() -> void:
	var _ignore
	if on_bump:
		_ignore = entity.get_component(Bumper.NAME).connect("bumped", self, "knockback")
	if on_attack:
		_ignore = entity.get_component(Attacker.NAME).connect("attacked", self, "knockback")

func knockback(other: Knockbackable) -> void:
	emit_signal("knocked_back", other)
	other.knockback(self)
