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
	var bumper: Component = backpack.entity.get_component(Bumpable.NAME)
	var dv := Direction.delta(dir)
	var dist := 1
	# Find first free square.
	while true:
		var gpos = backpack.entity.grid_position + dv * dist
		if tile_system.blocks_movement(gpos.x, gpos.y):
			break
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		var clear := true
		for ent in entities:
			var bumpable = ent.get_component(Bumpable.NAME)
			var jumpable = ent.get_component(Jumpable.NAME)
			# Entities must be jumpable.
			if not jumpable:
				return false
			# Okay, they're jumpable.  If they're bumpable and must be bumped but can't, we also fail.
			if bumpable:
				clear = false
				if bumpable.must_bump and not bumper.does_bump(bumpable):
					return false

		if clear:
			self.charge = 0
			backpack.entity.move(gpos)
			return true
		dist += 1
	return false
