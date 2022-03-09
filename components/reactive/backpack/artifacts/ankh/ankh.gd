extends Artifact

onready var health: Health

func _ready() -> void:
	if backpack:
		health = backpack.entity.get_component(Health.NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir: int) -> bool:
	assert(health)
	if health.health == health.max_health:
		return false
	health.health += 999
	self.charge = 0
	return true
