extends Node2D
class_name State

##
## A child state of a StateMachine.
##

onready var state_machine: StateMachine = get_parent()

func enter(msg=null) -> void:
	pass

func exit() -> void:
	pass

func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	pass

func unhandled_input(event: InputEvent) -> void:
	pass
