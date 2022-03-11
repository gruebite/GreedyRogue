extends Artifact

onready var tile_system: TileSystem
onready var effect_system: EffectSystem
onready var entity_system: EntitySystem
onready var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var bumper: Component = backpack.entity.get_component(Bumper.NAME)
	var dv := Direction.delta(dir)
	var dist := 1
	# Find first free square.
	while true:
		var gpos = backpack.entity.grid_position + dv * dist
		if tile_system.blocks_movement(gpos.x, gpos.y):
			return false
		# Can jump over jumpables, a place is clear if we're not a bumper or there isn't a
		# bumpable we can bump.
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		# We assume to land.  If there are entities we check if they can be jumped, or it's not
		# clear to land.
		var landing := true
		for ent in entities:
			var bumpable = ent.get_component(Bumpable.NAME)
			var jumpable = ent.get_component(Jumpable.NAME)
			# We jumping or landing?
			if jumpable:
				landing = false
			# Can we pass?
			if bumper and bumpable:
				if bumpable.must_bump and not bumper.does_bump(bumpable):
					return false

		if landing:
			self.charge = 0
			effect_system.add_effect(preload("res://effects/spell_cast/spell_cast.tscn"), backpack.entity.position)
			backpack.entity.move(gpos)
			return true
		dist += 1
	return false
