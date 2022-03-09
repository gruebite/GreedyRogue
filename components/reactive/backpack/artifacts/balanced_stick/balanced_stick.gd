extends Artifact

onready var tile_system: TileSystem
onready var entity_system: EntitySystem

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var attacker: Attacker = backpack.entity.get_component(Attacker.NAME)
	# Assumption, because only player.
	assert(attacker)
	var dv := Direction.delta(dir)
	var gpos = backpack.entity.grid_position + dv
	if tile_system.out_of_bounds(gpos.x, gpos.y):
		return false
	var entities := entity_system.get_entities(gpos.x, gpos.y)
	var attacked := false
	attacker.powerup(level + 1)
	for ent in entities:
		var defender: Defender = ent.get_component(Defender.NAME)
		if defender:
			attacked = true
			defender.attack(backpack.entity)
	attacker.powerdown(level + 1)
	return attacked
