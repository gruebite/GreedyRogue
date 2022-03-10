extends Component
class_name Elemental

const NAME := "Elemental"

enum State {
	STILL,
	WANDERING,
	PURSUING,
}

signal thinking()
signal still()
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

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

export(State) var state: int = State.WANDERING
var last_dir := Vector2.ZERO

func _ready() -> void:
	var _ignore = entity.get_component("TurnTaker").connect("take_turn", self, "_on_take_turn")

func _exit_tree() -> void:
	turn_system.finish_turn(self)

func _on_take_turn() -> void:
	check_transitions()
	emit_signal("thinking")
	match state:
		State.STILL:
			emit_signal("still")
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
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
				emit_signal("wandering")
		State.PURSUING:
			if randf() <= distracted_chance:
				var dv := Direction.delta(Direction.CARDINALS[randi() % 4])
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
				emit_signal("distracted")
			else:
				var dv := Direction.delta(navigation_system.cardinal_to(entity, entity_system.player))
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
				emit_signal("pursuing")
	emit_signal("thunk")


func check_transitions():
	if fleeting:
		return
	match state:
		State.WANDERING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= notice_range:
				state = State.PURSUING
		State.PURSUING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y > pursue_range:
				state = State.WANDERING
