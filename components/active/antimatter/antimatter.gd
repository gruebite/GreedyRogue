extends Component
class_name Antimatter

export(PoolStringArray) var self_annihilating := []
export(PoolStringArray) var anticomponents := []
export(PoolStringArray) var excluding := []

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	var turn_taker: TurnTaker = entity.get_component("TurnTaker")
	if turn_taker:
		_ignore = turn_taker.connect("manual_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var matters := entity_system.get_components(gpos.x, gpos.y, Matter.NAME)
	# Only effect matter.
	var self_annihilate := false
	for matter in matters:
		# Don't annihilate ourselves.
		if matter.entity == entity:
			continue
		var exclude := false
		for i in excluding.size():
			var comp = excluding[i]
			if matter.entity.get_component(comp):
				exclude = true
				break
		if exclude:
			continue
		var do_annihilate := false
		var will_self_annihilate := false
		for i in anticomponents.size():
			var comp = anticomponents[i]
			if matter.entity.get_component(comp):
				do_annihilate = true
				if comp in self_annihilating:
					will_self_annihilate = true
					break
		if do_annihilate:
			matter.entity.kill("annihilated")
		self_annihilate = will_self_annihilate
	if self_annihilate:
		entity.kill("annihilated")
