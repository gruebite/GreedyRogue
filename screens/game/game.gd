extends Node2D
class_name Game

func _ready() -> void:
	var _ignore = get_tree().change_scene("res://screens/lair/lair.tscn")
