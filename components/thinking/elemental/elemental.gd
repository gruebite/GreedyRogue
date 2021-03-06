extends Component
class_name Elemental

const NAME := "Elemental"

enum State {
	BLANKING,
	WANDERING,
	PURSUING,
}

signal thinking()
signal blanking()
signal wandering()
signal idling()
signal pursuing()
signal distracted()
signal thunk()

# Fleeting elementals stay in the same state.
export var fleeting := false

export var notice_range := 3
export var pursue_range := 6

export var idle_chance := 0.0
## Whether there is bias to continue in the same direction.
export var bias := false
## How often a random movement is made while pursuing.
export var distracted_chance := 0.0
## Whether to use astar when pursuing.
export var use_astar := false

export(State) var state: int = State.WANDERING
var last_dir := Vector2.ZERO

export(PoolStringArray) var excluding := []

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

# TODO: Used for "stealth".  If bright is disabled, player is stealthy.
onready var player_bright: Bright = entity_system.player.get_component(Bright.NAME)

## Used by behaviors to skip the turn, because it was handled so other way.
var skip_this_turn := false

func _ready() -> void:
	var _ignore = entity.get_component("TurnTaker").connect("take_turn", self, "_on_take_turn")

func _exit_tree() -> void:
	turn_system.finish_turn(self)

func _on_take_turn() -> void:
	check_transitions()
	emit_signal("thinking")
	if skip_this_turn:
		skip_this_turn = false
	else:
		match state:
			State.BLANKING:
				emit_signal("blanking")
			State.WANDERING:
				if randf() <= idle_chance:
					emit_signal("idling")
				else:
					var dv0 := Direction.delta(Direction.CARDINALS[randi() % 4])
					var dv := dv0
					if bias:
						var dv1 := Direction.delta(Direction.CARDINALS[randi() % 4])
						if dv0 == last_dir or dv1 == last_dir:
							dv = last_dir
					var desired := entity.grid_position + dv
					if navigation_system.can_move_to(entity, desired, excluding):
						navigation_system.move_to(entity, desired)
						last_dir = dv
					emit_signal("wandering")
			State.PURSUING:
				if randf() <= distracted_chance:
					var dv := Direction.delta(Direction.CARDINALS[randi() % 4])
					var desired := entity.grid_position + dv
					if navigation_system.can_move_to(entity, desired, excluding):
						navigation_system.move_to(entity, desired)
					emit_signal("distracted")
				elif use_astar:
					var path := navigation_system.path_to(entity.grid_position, entity_system.player.grid_position)
					if path.size() >= 2:
						var desired := navigation_system.path_vector(path[1])
						if navigation_system.can_move_to(entity, desired, excluding):
							navigation_system.move_to(entity, desired)
					emit_signal("pursuing")
				else:
					var dv := Direction.delta(navigation_system.cardinal_to(entity.grid_position, entity_system.player.grid_position))
					var desired := entity.grid_position + dv
					if navigation_system.can_move_to(entity, desired, excluding):
						navigation_system.move_to(entity, desired)
					emit_signal("pursuing")
	emit_signal("thunk")


func check_transitions():
	if fleeting:
		return
	match state:
		State.WANDERING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= notice_range and not player_bright.disabled:
				state = State.PURSUING
		State.PURSUING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y > pursue_range and not player_bright.disabled:
				state = State.WANDERING
