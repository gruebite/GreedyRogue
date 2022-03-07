extends Node2D
class_name Lair

onready var player: Entity = $EntitySystem.player

var loading = null

func _ready() -> void:
	var _ignore
	_ignore = player.get_component(Backpack.NAME).connect("gold_changed", self, "_on_gold_changed")
	_ignore = player.get_component(Health.NAME).connect("health_changed", self, "_on_health_changed")
	_ignore = player.get_component(Anxiety.NAME).connect("anxiety_changed", self, "_on_anxiety_changed")
	_ignore = player.get_component(Controller.NAME).connect("found_exit", self, "_on_found_exit")
	
	regenerate()

func _process(_delta: float) -> void:
	if not loading:
		return
	
	if loading is GDScriptFunctionState and loading.is_valid():
		loading = loading.resume()
		$UI/Loading/Label.text += "."
	
	if not loading:
		$UI/Loading.hide()
		$TurnSystem.disabled = false

func _on_gold_changed(to: int) -> void:
	$UI/HUD/VBoxContainer/Gold/Value.text = str(to)

func _on_health_changed(to: int, _mx: int) -> void:
	$UI/HUD/VBoxContainer/Health/Value.text = "♥".repeat(ceil(to))

func _on_anxiety_changed(to: int, mx: int) -> void:
	var slots := 10
	var p := to / float(mx)
	$UI/HUD/VBoxContainer/Anxiety/Value.text = "‼".repeat(ceil(p * slots))

func _on_found_exit() -> void:
	pass

func regenerate() -> void:
	$UI/Loading.show()
	$UI/Loading/Label.text = "Loading\n"
	loading = $GeneratorSystem.generate()
	$TurnSystem.disabled = true
