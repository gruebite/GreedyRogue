extends Component
class_name Defend

const NAME := "Defend"

onready var health := entity.get_component(Health.NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")

func _on_bumped(by: Entity) -> void:
	var dmg := 0
	var attack: Attack = by.get_component(Attack.NAME)
	if attack:
		dmg = attack.damage
	health.health -= dmg
