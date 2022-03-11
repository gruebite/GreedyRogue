extends Component
class_name Attacker

const NAME := "Attacker"

signal attacked(other)

export var damage := 1
var power := 0
var true_damage: int setget , get_true_damage

func _ready() -> void:
	var bumper: Bumper = entity.get_component(Bumper.NAME)
	if bumper:
		var _ignore = bumper.connect("bumped", self, "_on_bumped")

func _on_bumped(other: Bumpable) -> void:
	var attackable: Attackable = other.entity.get_component(Attackable.NAME)
	if attackable:
		emit_signal("attacked", attackable)
		attackable.attack(self)

func get_true_damage() -> int:
	return damage + power

func powerup(by: int) -> void:
	power += by

func powerdown(by: int) -> void:
	power -= by

func attack(attackable: Attackable) -> void:
	emit_signal("attacked", attackable)
	attackable.attack(self)
