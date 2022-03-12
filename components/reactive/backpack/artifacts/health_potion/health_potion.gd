extends Artifact

var health: Health

func _ready() -> void:
	if backpack:
		health = backpack.entity.get_component(Health.NAME)

func use(_dir: int) -> bool:
	health.deal_damage(-100)
	queue_free()
	return true
