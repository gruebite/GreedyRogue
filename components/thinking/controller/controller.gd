extends Component
class_name Controller

const NAME := "Controller"

signal found_exit()
# Used visually.
signal activated_artifact(index)
signal deactivated_artifact(index)

onready var bright_sytem: BrightSystem = find_system(BrightSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

onready var backpack: Backpack = entity.get_component(Backpack.NAME)
onready var anxiety: Anxiety = entity.get_component(Anxiety.NAME)

# Only used for direction select.
var using_artifact := -1

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")

	entity.grid_position = Vector2(Constants.MAP_COLUMNS / 2, Constants.MAP_ROWS / 2).floor()

func _exit_tree() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:

	var delta := Vector2.ZERO
	if event.is_action_pressed("ui_accept"):
		pass
	elif event.is_action_pressed("ui_cancel"):
		if using_artifact != -1:
			chose_artifact_direction(-1)
			return
	elif event.is_action_pressed("ui_up", true):
		if using_artifact != -1:
			chose_artifact_direction(Direction.NORTH)
			return
		delta = Vector2.UP
	elif event.is_action_pressed("ui_down", true):
		if using_artifact != -1:
			chose_artifact_direction(Direction.SOUTH)
			return
		delta = Vector2.DOWN
	elif event.is_action_pressed("ui_left", true):
		if using_artifact != -1:
			chose_artifact_direction(Direction.WEST)
			return
		delta = Vector2.LEFT
	elif event.is_action_pressed("ui_right", true):
		if using_artifact != -1:
			chose_artifact_direction(Direction.EAST)
			return
		delta = Vector2.RIGHT
	elif event.is_action_pressed("ui_1"):
		use_artifact(0)
		return
	elif event.is_action_pressed("ui_2"):
		use_artifact(1)
		return
	elif event.is_action_pressed("ui_3"):
		use_artifact(2)
		return
	elif event.is_action_pressed("ui_4"):
		use_artifact(3)
		return
	elif event.is_action_pressed("ui_5"):
		use_artifact(4)
		return
	elif event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_F:
				entity_system.add_entity(preload("res://entities/fire/fire.tscn").instance(), entity.grid_position)
			KEY_A:
				entity_system.add_entity(preload("res://entities/falling_rock/falling_rock.tscn").instance(), entity.grid_position)
			KEY_R:
				entity_system.add_entity(preload("res://entities/rock/rock.tscn").instance(), entity.grid_position)
			KEY_T:
				entity_system.add_entity(preload("res://entities/treasure_chest/treasure_chest.tscn").instance(), entity.grid_position)

	# Hacky mouse detection.
	if event is InputEventMouseButton:
		if event.pressed:
			var center := Constants.MAP_RESOLUTION / 2
			var angle: float = (event.position - center).angle()
			delta = Direction.delta(Direction.angle_to_cardinal_direction(angle))

	if delta != Vector2.ZERO and turn_system.can_initiate_turn():
		var desired := entity.grid_position + delta
		if navigation_system.can_move_to(entity, desired):
			turn_system.will_initiate_turn()
			navigation_system.move_to(entity, desired)
			bright_sytem.update_brights()
			bright_sytem.update_tiles()
			turn_system.initiate_turn()

func _on_out_of_turn() -> void:
	var gpos := entity.grid_position
	if navigation_system.is_edge(gpos.x, gpos.y):
		var is_lava := navigation_system.is_lava(gpos.x, gpos.y)
		# Can't exit through lava.
		if not is_lava:
			emit_signal("found_exit")

func use_artifact(index: int) -> void:
	var artifact: Artifact = backpack.get_artifact(index)
	if not artifact:
		return
	if not artifact.usable():
		return
	# Wait for directional input.
	if artifact.directional:
		using_artifact = index
		entity.get_component(Arrows.NAME).show()
		emit_signal("activated_artifact", index)
		return
	turn_system.will_initiate_turn()
	if artifact.use(-1):
		turn_system.initiate_turn()
	else:
		turn_system.will_not_initiate_turn()

func chose_artifact_direction(dir: int) -> void:
	assert(using_artifact != -1)
	entity.get_component(Arrows.NAME).hide()
	turn_system.will_initiate_turn()
	if dir != -1 and backpack.get_artifact(using_artifact).use(dir):
		turn_system.initiate_turn()
	else:
		turn_system.will_not_initiate_turn()
	emit_signal("deactivated_artifact", using_artifact)
	using_artifact = -1
