extends Component
class_name Health

const NAME := "Health"

signal health_changed(to)

export var flashing_node_path := NodePath("../Display")
export var max_health := 10
var health := max_health setget set_health

export var transparency: float = 0 setget set_transparency

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var flashing_node := get_node(flashing_node_path)

func _exit_tree() -> void:
	turn_system.finish_turn(self)

func set_health(to: int) -> void:
	if to < 0: to = 0
	if to > max_health: to = max_health
	if to < health:
		flash()
	health = to
	if health == 0:
		entity.kill(self)
	emit_signal("health_changed", health, max_health)

func set_transparency(value: float) -> void:
	transparency = value
	if flashing_node:
		flashing_node.modulate.a = 1 - transparency

func flash() -> void:
	$AnimationPlayer.play("flash")
	# Only do this if we're in turn.
	#if turn_system.state == TurnSystem.IN_TURN:
	turn_system.taking_turn(self)
	yield($AnimationPlayer, "animation_finished")
	turn_system.finish_turn(self)
