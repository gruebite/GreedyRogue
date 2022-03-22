extends Artifact

var tile_system: TileSystem
var effect_system: EffectSystem
var entity_system: EntitySystem
var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
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
	# Keep finding bumpables and moves until a space one can move, backtrack moving things
	# if able.  It's okay if we get to a spot where they can't move even after moving them.
	var ent_spot_stack := []
	while true:
		var gpos = backpack.entity.grid_position + dv * dist
		# Dead end.
		if tile_system.blocks_movement(gpos.x, gpos.y):
			return false
		# Check entities that are bumpable and moves and add them to the stack.
		var entities := entity_system.get_entities(gpos.x, gpos.y)
		var eligible_ents := []
		for ent in entities:
			var bumpable = ent.get_component(Bumpable.NAME)
			var moves = ent.get_component(Moves.NAME)
			if bumpable and moves:
				eligible_ents.append(ent)
		# No bumpables, we're clear.
		if eligible_ents.size() == 0:
			break
		ent_spot_stack.append(eligible_ents)
		dist += 1

	# Two paths, one to check if we're dealing with one bumpable, the other to push multiple.
	if ent_spot_stack.size() == 1:
		var pushing: Array = ent_spot_stack.pop_back()
		# Push until we hit a wall, or get freed somehow.
		dist = 2
		while true:
			# Incrementing gpos so we pass through bumpables.
			var gpos = backpack.entity.grid_position + dv * dist
			var i := pushing.size()
			while i > 0:
				i -= 1
				var pushing_ent = pushing[i]
				if pushing_ent.dead or not navigation_system.can_move_to(pushing_ent, gpos):
					# Done pushing.
					pushing.remove(i)
				else:
					navigation_system.move_to(pushing_ent, gpos)
					# Manually do an in turn update.
					var turn_taker: TurnTaker = pushing_ent.get_component("TurnTaker")
					if turn_taker:
						turn_taker.emit_signal("take_inturn")
					# Gotta check again.
					if pushing_ent.dead:
						pushing.remove(i)
			if pushing.size() == 0:
				break
			effect_system.add_effect(
				preload("res://effects/splash/splash.tscn"),
				gpos, Palette.BROWN_4)
			dist += 1
		self.charge = 0
	else:
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

		if at_least_1:
			self.charge = 0

	return true
