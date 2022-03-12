extends Artifact

var health: Health
var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		health = backpack.entity.get_component(Health.NAME)
		anxiety = backpack.entity.get_component(Anxiety.NAME)

func use(_dir: int) -> bool:
	health.deal_damage(-6)
	anxiety.anxiety -= 100
	queue_free()
	return true
