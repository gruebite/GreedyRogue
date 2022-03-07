extends Component
class_name Controller

const NAME := "Controller"

signal found_exit()

onready var bright_sytem: BrightSystem = find_system(BrightSystem.GROUP_NAME)
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

func _exit_tree() -> void:
	pass

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
	elif event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_F:
				entity_system.spawn_entity(preload("res://entities/fire/fire.tscn"), entity.grid_position)
			KEY_A:
				entity_system.spawn_entity(preload("res://entities/falling_rock/falling_rock.tscn"), entity.grid_position)
			KEY_R:
				entity_system.spawn_entity(preload("res://entities/rock/rock.tscn"), entity.grid_position)

	# Hacky mouse detection.
	if event is InputEventMouseButton:
		if event.pressed:
			var center := Constants.MAP_RESOLUTION / 2
			var angle: float = (event.position - center).angle()
			delta = Direction.delta(Direction.angle_to_cardinal_direction(angle))

	if delta != Vector2.ZERO and turn_system.can_initiate_turn():
		var desired := entity.grid_position + delta
		if navigation_system.out_of_bounds(desired.x, desired.y):
			var on_lava: bool = false
			for matter in entity_system.get_components(desired.x, desired.y, Matter.NAME):
				if Matter.LAVA & matter.mask:
					on_lava = true
					break
			# Can't exit through lava.
			if not on_lava:
				emit_signal("found_exit")
		if navigation_system.can_move_to(entity, desired):
			turn_system.will_initiate_turn()
			navigation_system.move_to(entity, desired)
			bright_sytem.update_brights()
			bright_sytem.update_tiles()
			turn_system.initiate_turn()

func _on_pickup(ent: Entity) -> void:
	var treasure: Treasure = ent.get_component(Treasure.NAME)
	if treasure:
		backpack.gold += treasure.gold
		anxiety.anxiety -= treasure.gold
