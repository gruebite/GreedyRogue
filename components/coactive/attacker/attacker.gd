extends Component
class_name Attacker

const NAME := "Attacker"

signal attacked(other)

export var damage := 1 setget , get_damage

var power := 0

func _ready() -> void:
	var bumper: Bumper = entity.get_component(Bumper.NAME)
	if bumper:
		var _ignore = bumper.connect("bumped", self, "_on_bumped")

func _on_bumped(other: Entity) -> void:
	var defender: Defender = other.get_component(Defender.NAME)
	if defender:
		defender.attack(entity)
		emit_signal("attacked", defender)

func get_damage() -> int:
	return damage + power

func powerup(by: int) -> void:
	power += by
	
func powerdown(by: int) -> void:
	power -= by