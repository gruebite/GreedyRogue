extends Component
class_name Slug

const NAME := "Slug"

enum {
	WANDERING,
	PURSUING,
}

export var notice_range := 4
export var pursue_range := 6

var state: int = WANDERING

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

var last_dir := Vector2.ZERO

func _ready() -> void:
	var _ignore = entity.get_component("TurnTaker").connect("take_turn", self, "_on_take_turn")

func _exit_tree() -> void:
	turn_system.finish_turn(self)

func _on_take_turn() -> void:
	check_transitions()
	match state:
		WANDERING:
			if randi() % 50 == 0:
				var dv0 := Direction.delta(Direction.CARDINALS[randi() % 4])
				var dv1 := Direction.delta(Direction.CARDINALS[randi() % 4])
				var dv := last_dir
				if dv0 != last_dir and dv1 != last_dir:
					dv = dv0
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
		PURSUING:
			if randi() % 3:
				var dv := Direction.delta(navigation_system.cardinal_to(entity, entity_system.player))
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)
			else:
				var dv := Direction.delta(Direction.CARDINALS[randi() % 4])
				var desired := entity.grid_position + dv
				if navigation_system.can_move_to(entity, desired):
					navigation_system.move_to(entity, desired)


func check_transitions():
	match state:
		WANDERING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= notice_range:
				state = PURSUING
		PURSUING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y > pursue_range:
				state = WANDERING
