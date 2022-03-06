extends Component
class_name Controller

const NAME := "Controller"

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

onready var backpack: Backpack = entity.get_component(Backpack.NAME)
onready var anxiety: Anxiety = entity.get_component(Anxiety.NAME)

func _ready() -> void:
	var pickup: Pickup = entity.get_component(Pickup.NAME)
	var _ignore = pickup.connect("picked_up", self, "_on_pickup")

	entity.grid_position = Vector2(Constants.MAP_COLUMNS / 2, Constants.MAP_ROWS / 2).floor()
	entity_system.update_entity(entity)

func _unhandled_input(event: InputEvent) -> void:

	var delta := Vector2.ZERO
	if event.is_action_pressed("ui_accept"):
		pass
	elif event.is_action_pressed("ui_up", true):
		delta = Vector2.UP
	elif event.is_action_pressed("ui_down", true):
		delta = Vector2.DOWN
	elif event.is_action_pressed("ui_left", true):
		delta = Vector2.LEFT
	elif event.is_action_pressed("ui_right", true):
		delta = Vector2.RIGHT

	if delta != Vector2.ZERO and turn_system.can_initiate_turn():
		var can_move := navigation_system.can_move_to(entity.grid_position + delta)
		if can_move:
			entity.move(entity.grid_position + delta)
			entity_system.update_entity(entity)
			turn_system.initiate_turn()

func _on_pickup(ent: Entity) -> void:
	var treasure: Treasure = ent.get_component(Treasure.NAME)
	if treasure:
		backpack.gold += treasure.gold
		anxiety.anxiety -= treasure.gold
