extends Artifact

var effect_system: EffectSystem
var entity_system: EntitySystem
var navigation_system: NavigationSystem
var tile_system: TileSystem

var bright: Bright

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)

		bright = backpack.entity.get_component(Bright.NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var knockbacker: Knockbacker = backpack.entity.get_component(Knockbacker.NAME)
	var bumper: Bumper = backpack.entity.get_component(Bumper.NAME)
	var i := 1
	var startv: Vector2 = backpack.entity.grid_position
	var dv := Direction.delta(dir)
	while i <= bright.lit_radius:
		var gpos: Vector2 = startv + dv * i
		if not navigation_system.can_move_to(backpack.entity, gpos):
			break
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		var hit := false
		for ent in entities:
			var bumpable: Bumpable = ent.get_component(Bumpable.NAME)
			if bumper.does_bump(bumpable):
				bumper.do_bump(bumpable)
				hit = true
			var knockbackable: Knockbackable = ent.get_component(Knockbackable.NAME)
			if knockbackable:
				knockbacker.knockback(knockbackable)
		if hit:
			break
		else:
			navigation_system.move_to(backpack.entity, gpos)
			effect_system.add_effect(preload("res://effects/cracking/cracking.tscn"), gpos)
		i += 1
	self.charge = 0
	# We return false because this is a free action.
	return false
