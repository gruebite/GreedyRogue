extends Component
class_name Antimatter

export(int, FLAGS, "LAVA", "FIRE") var free_self_mask := 0
export(int, FLAGS, "LAVA", "FIRE") var mask := 0

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("in_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var matters := entity_system.get_components(gpos.x, gpos.y, Matter.NAME)
	for matter in matters:
		if free_self_mask & matter.mask:
			matter.entity.queue_free()
			entity.queue_free()
		elif mask & matter.mask:
			matter.entity.queue_free()
