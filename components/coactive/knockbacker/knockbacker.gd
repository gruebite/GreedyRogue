extends Component
class_name Knockbacker

const NAME := "Knockbacker"

signal knocked_back(other)

export var on_bump := false
export var on_attack := false

func _ready() -> void:
	var _ignore
	if on_bump:
		_ignore = entity.get_component(Bumper.NAME).connect("bumped", self, "_on_bumped")
	if on_attack:
		_ignore = entity.get_component(Attacker.NAME).connect("attacked", self, "_on_attacked")

func _on_bumped(by: Bumpable) -> void:
	var kb: Knockbackable = by.entity.get_component(Knockbackable.NAME)
	if kb:
		knockback(kb)

func _on_attacked(by: Attackable) -> void:
	var kb: Knockbackable = by.entity.get_component(Knockbackable.NAME)
	if kb:
		knockback(kb)

func knockback(other: Knockbackable) -> void:
	emit_signal("knocked_back", other)
	other.knockback(self)
