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
	var gpos: Vector2 = backpack.entity.grid_position
	if navigation_system.is_near_lava(gpos.x, gpos.y):
		self.charge += 1

func use(dir: int) -> bool:
	var i := 1
	var dv := Direction.delta(dir)
	while true:
		var gpos: Vector2 = backpack.entity.grid_position + dv * i
		if tile_system.blocks_movement(gpos.x, gpos.y):
			break
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		var hit := false
		for ent in entities:
			var health: Health = ent.get_component(Health.NAME)
			if health:
				health.deal_damage(level + 1)
				hit = true
		if hit:
			break
		else:
			effect_system.add_effect(preload("res://effects/laser/laser.tscn"), gpos * Constants.CELL_SIZE)
		i += 1
	self.charge = 0
	return true
