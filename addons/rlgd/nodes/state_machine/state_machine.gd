extends Node2D
class_name StateMachine

signal state_changed(previous, new)

export var initial_state := NodePath()
var is_active := true setget set_is_active

onready var current_state = get_node(initial_state) setget , get_current_state

func _init() -> void:
	add_to_group("state_machine")

func _ready() -> void:
	current_state.enter()

func _process(delta: float):
	current_state.process(delta)

func _physics_process(delta: float):
	current_state.physics_process(delta)

func _input(event: InputEvent):
	current_state.input(event)

func _unhandled_input(event: InputEvent):
	current_state.unhandled_input(event)

func transition_to(target_state_path: NodePath, msg=null) -> void:
	if not has_node(target_state_path):
		return

	var target_state := get_node(target_state_path)
	if target_state.name == current_state.name:
		return

	var prev_state = current_state

	current_state.exit()
	current_state = target_state
	current_state.enter(msg)

	emit_signal("state_changed", prev_state, current_state)

func set_is_active(value: bool) -> void:
	is_active = value
	set_process(value)
	set_physics_process(value)
	set_process_input(value)
	set_process_unhandled_input(value)
	set_block_signals(not value)

func get_current_state() -> Node2D:
	return current_state
