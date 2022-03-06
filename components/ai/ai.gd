extends Component
class_name Ai

const NAME := "Ai"

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.get_component("TurnTaker").connect("take_turn", self, "_on_take_turn")

func _on_take_turn() -> void:
	var dir := Direction.delta(Direction.CARDINALS[randi() % 4])
	var desired := entity.grid_position + dir
	if navigation_system.can_move_to(entity, desired, NavigationSystem.Ignore.ENTITIES):
		entity.grid_position = desired
		entity_system.update_entity(entity)
