extends Component
class_name Controller

const NAME := "Controller"

signal found_exit()
signal picked_up_gold()
signal picked_up_treasure()

onready var bright_sytem: BrightSystem = find_system(BrightSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

onready var backpack: Backpack = entity.get_component(Backpack.NAME)
onready var anxiety: Anxiety = entity.get_component(Anxiety.NAME)

func _ready() -> void:
	var _ignore
	_ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")
	_ignore = entity.get_component(Pickup.NAME).connect("picked_up", self, "_on_pickup")

	entity.grid_position = Vector2(Constants.MAP_COLUMNS / 2, Constants.MAP_ROWS / 2).floor()

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
		var on_lava := navigation_system.on_lava(gpos.x, gpos.y)
		# Can't exit through lava.
		if not on_lava:
			emit_signal("found_exit")

func _on_pickup(ent: Entity) -> void:
	if ent.get_component(Gold.NAME):
		backpack.gold += (randi() % 5) + 5
		anxiety.anxiety -= 10
		effect_system.add_effect(preload("res://effects/collect_gold/collect_gold.tscn").instance(), entity.position)
		emit_signal("picked_up_gold")
	if ent.get_component(Treasure.NAME):
		emit_signal("picked_up_treasure")
