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
	var dv := Direction.delta(dir)
	var dist := 1
	# Find first free square.
	while true:
		var gpos = backpack.entity.grid_position + dv * dist
		if tile_system.blocks_movement(gpos.x, gpos.y):
			break
		var jumpables := entity_system.get_components(gpos.x, gpos.y, Jumpable.NAME)
		if jumpables.size() == 0:
			self.charge = 0
			backpack.entity.move(gpos)
			return true
		dist += 1
	return false
