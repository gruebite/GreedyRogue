extends Component
class_name Antimatter

export(PoolStringArray) var self_annihilate := []
export(PoolStringArray) var anticomponents := []

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
	for matter in matters:
		for i in anticomponents.size():
			var comp = anticomponents[i]
			if matter.entity.get_component(comp):
				matter.entity.kill("annihilated")
				if comp in self_annihilate:
					entity.kill("annihilated")
				# Only do the first.
				return
