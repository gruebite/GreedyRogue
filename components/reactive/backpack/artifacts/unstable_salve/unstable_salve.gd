extends Artifact

var entity_system: EntitySystem
var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		anxiety = backpack.entity.get_component(Anxiety.NAME)

func _on_initiated_turn() -> void:
	if self.charge_p == 1:
		anxiety.anxiety += 1

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var gpos: Vector2 = backpack.entity.grid_position + Direction.delta(dir)
	var bombs := entity_system.get_components(gpos.x, gpos.y, Bomb.NAME)
	if bombs.size() == 0:
		return false
	for b in bombs:
		b.radius = (level * 2) + 2
		b.active = true
	self.charge = 0
	return true
