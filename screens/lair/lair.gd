extends Node2D
class_name Lair

onready var player: Entity = $Entities/Player

func _ready() -> void:
	$GeneratorSystem.generate()
	var _ignore
	_ignore = player.get_component(Backpack.NAME).connect("gold_changed", self, "_on_gold_changed")
	_ignore = player.get_component(Anxiety.NAME).connect("anxiety_changed", self, "_on_anxiety_changed")

func _on_gold_changed(to: int) -> void:
	$UI/HUD/VBoxContainer/Gold/Value.text = str(to)

func _on_anxiety_changed(to: int, mx: int) -> void:
	var slots := 10
	var p := to / float(mx)
	$UI/HUD/VBoxContainer/Anxiety/Value.text = "‼".repeat(ceil(p * slots))
