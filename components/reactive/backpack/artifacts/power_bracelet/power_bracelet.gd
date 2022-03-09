extends Artifact

onready var tile_system: TileSystem
onready var entity_system: EntitySystem
onready var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var bumper: Component = backpack.entity.get_component(Bumpable.NAME)
	# We need to bump things to move them.
	if not bumper:
		return false
	var dv := Direction.delta(dir)
	var dist := 1
	# Keep finding bumpables and moveables until a space one can move, backtrack moving things
	# if able.  It's okay if we get to a spot where they can't move even after moving them.
	var ent_spot_stack := []
	while true:
		var gpos = backpack.entity.grid_position + dv * dist
		# Dead end.
		if tile_system.blocks_movement(gpos.x, gpos.y):
			return false
		# Check entities that are bumpable and moveable and add them to the stack.
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		# No entities, we're clear.
		if entities.size() == 0:
			break
		var eligible_ents := []
		for ent in entities:
			var bumpable = ent.get_component(Bumpable.NAME)
			var moveable = ent.get_component(Moveable.NAME)
			if bumpable and moveable:
				eligible_ents.append(ent)
		ent_spot_stack.append(eligible_ents)
		dist += 1

	var at_least_1 := false
	# Backtrack, pull entities that can move.
	while ent_spot_stack.size() > 0:
		var eligible_ents: Array = ent_spot_stack.pop_back()
		var dest = backpack.entity.grid_position + dv * dist
		for ent in eligible_ents:
			if navigation_system.can_move_to(ent, dest):
				navigation_system.move_to(ent, dest)
				at_least_1 = true
		dist -= 1

	return at_least_1
