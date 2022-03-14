extends Artifact

var health: Health
var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		health = backpack.entity.get_component(Health.NAME)
		anxiety = backpack.entity.get_component(Anxiety.NAME)

func use(_dir: int) -> bool:
	var new_level := self.level - 1
	if new_level <= 0:
		queue_free()
	self.level = new_level
	health.deal_damage(-6)
	anxiety.anxiety -= 100
	return true
