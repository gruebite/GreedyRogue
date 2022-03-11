extends Artifact

var effect_system: EffectSystem
var entity_system: EntitySystem
var navigation_system: NavigationSystem
var tile_system: TileSystem

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var dist := 1
	var dv := Direction.delta(dir)
	while true:
		var gpos: Vector2 = backpack.entity.grid_position + dv * dist
		if navigation_system.out_of_bounds(gpos.x, gpos.y):
			return false
		if not tile_system.blocks_movement(gpos.x, gpos.y):
			# Don't want to waste this on a regular move.
			if dist == 1:
				return false

			# We're not moving to interact, so just a regular move.
			backpack.entity.move(gpos)
			break
		else:
			effect_system.add_effect(preload("res://effects/cracking/cracking.tscn"), gpos)
		dist += 1
	self.charge = 0
	# We return false because this is a free action.
	return false
