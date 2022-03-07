extends Component
class_name Dragon

const NAME := "Dragon"

enum {
	SLEEPING,
	WANDERING,
	BREATHING,
	PURSUING,
}

signal woke_up()

export var awake_dist := 3
export var sight_range := 6
export var dim_range := 4
export var lit_range := 1
export var breath_weapon_chance := 0.1
export var breath_weapon_time := 2
export var breath_weapon_range := 5

# Scale.
export var breathing_node_path := NodePath("../Display")
export var breath := 1.0 setget set_breath

var state: int = SLEEPING
var breath_timer: int = 0

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)
onready var security_system: SecuritySystem = find_system(SecuritySystem.GROUP_NAME)
onready var player_anxiety: Anxiety = entity_system.player.get_component(Anxiety.NAME)

onready var breathing_node: Node2D = get_node(breathing_node_path)

func _ready() -> void:
	security_system.add_dragon(self)
	var _ignore = entity.get_component("TurnTaker").connect("take_turn", self, "_on_take_turn")

func _exit_tree() -> void:
	security_system.remove_dragon(self)
	turn_system.finish_turn(self)

func _on_take_turn() -> void:
	check_transitions()
	match state:
		SLEEPING:
			# Nothing.
			pass
		WANDERING:
			if randi() % 2:
				var dv := Direction.delta(Direction.CARDINALS[randi() % 4])
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
		BREATHING:
			if breath_timer == breath_weapon_time:
				$AnimationPlayer.play("breath_in")
			if breath_timer == 0:
				$AnimationPlayer.play("breath_out")
				breath_fire(Direction.CARDINALS[randi() % 4])
				state = WANDERING
			else:
				breath_timer -= 1
		PURSUING:
			if randi() % 5:
				var dv: Vector2 = entity_system.player.grid_position - entity.grid_position
				dv.x = sign(dv.x)
				dv.y = sign(dv.y)
				if dv.x != 0 and dv.y != 0:
					if randi() % 2 == 0:
						dv.x = 0
					else:
						dv.y = 0
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
			else:
				var dv := Direction.delta(Direction.CARDINALS[randi() % 4])
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
			player_anxiety.panic = 2


func check_transitions():
	match state:
		SLEEPING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= awake_dist:
				wake_up()
		WANDERING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= sight_range:
				state = PURSUING
			else:
				if randf() <= breath_weapon_chance:
					state = BREATHING
					breath_timer = breath_weapon_time
		BREATHING:
			pass
		PURSUING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y > sight_range:
				state = WANDERING

func wake_up() -> void:
	if state != SLEEPING:
		return
	state = WANDERING
	var bright: Bright = preload("res://components/bright/bright.tscn").instance()
	bright.dynamic = true
	bright.lit_radius = lit_range
	bright.dim_radius = dim_range
	entity.add_child(bright)
	emit_signal("woke_up")

func breath_fire(dir: int) -> void:
	var cone := PointSets.cone(dir, breath_weapon_range, 0.5)
	var dirv := Direction.delta(dir)
	for dv in cone.array:
		var gpos: Vector2 = entity.grid_position + dv + dirv
		if tile_system.blocks_movement(gpos.x, gpos.y):
			continue
		entity_system.spawn_entity(preload("res://entities/fire/fire.tscn"), gpos)

func set_breath(value: float) -> void:
	breath = value
	if breathing_node:
		breathing_node.scale = Vector2(breath, breath)

