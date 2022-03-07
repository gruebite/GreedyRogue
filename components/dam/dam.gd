extends Component
class_name Dam

const NAME := "Dam"

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("in_turn", self, "_on_in_turn")

func _on_in_turn() -> void:
	var gpos := entity.grid_position
	var ents := entity_system.get_entities(gpos.x, gpos.y)
	for ent in ents:
		var dammable: Dammable = ent.get_component(Dammable.NAME)
		if dammable:
			dammable.entity.queue_free()
			entity.queue_free()
