extends Node2D
class_name Lair

onready var player: Entity = $EntitySystem.player

var loading = null
var game_over := false
var gold_p := 0.0
var panicking := false

func _ready() -> void:
	var _ignore
	_ignore = player.connect("died", self, "_on_player_died")
	_ignore = player.get_component(Backpack.NAME).connect("gold_changed", self, "_on_gold_changed")
	_ignore = player.get_component(Health.NAME).connect("health_changed", self, "_on_health_changed")
	_ignore = player.get_component(Anxiety.NAME).connect("anxiety_changed", self, "_on_anxiety_changed")
	_ignore = player.get_component(Anxiety.NAME).connect("panicking", self, "_on_panicking")
	_ignore = player.get_component(Anxiety.NAME).connect("calmed_down", self, "_on_calmed_down")
	_ignore = player.get_component(Controller.NAME).connect("found_exit", self, "_on_found_exit")

	regenerate()

func _process(_delta: float) -> void:
	if panicking:
		$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2(
			randf() * 5 - 2.5, randf() * 5 - 2.5)

	if not loading:
		return

	if loading is GDScriptFunctionState and loading.is_valid():
		loading = loading.resume()
		append_message(".")

	if not loading:
		hide_message()
		$UI/Loading.hide()

func _input(event: InputEvent) -> void:
	if not $UI/Message.visible:
		return
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			hide_message()
			if game_over:
				regenerate()
	if event is InputEventMouseButton:
		if event.pressed:
			hide_message()
			if game_over:
				regenerate()

func _on_player_died(_by: Node2D) -> void:
	show_message("Died\nCollected %.2f%% of the gold" % [gold_p * 100])
	game_over = true

func _on_gold_changed(to: int) -> void:
	gold_p = (float(to) / max(1, $GeneratorSystem.gold_total))
	print("Gold percentage: " + str(gold_p * 100))
	$SecuritySystem.gold_p = gold_p
	$UI/HUD/VBoxContainer/Gold/Value.text = str(to)

func _on_health_changed(to: int, mx: int) -> void:
	$UI/HUD/VBoxContainer/Health/Value.value = (float(to) / mx) * 100

func _on_anxiety_changed(to: int, mx: int) -> void:
	$UI/HUD/VBoxContainer/Anxiety/Value/Progress.value = (float(to)) / mx * 100

func _on_panicking(_amount: int) -> void:
	panicking = true

func _on_calmed_down() -> void:
	panicking = false
	$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2.ZERO

func _on_found_exit() -> void:
	if gold_p < 0.5:
		show_message("Refuse to leave with less than 50%% of the gold\nCollected %.2f%%" % (gold_p * 100))
		return
	show_message("Found an escape!\nCollected %.2f%% of the gold" % (gold_p * 100))
	game_over = true

func regenerate() -> void:
	game_over = false
	show_message("Loading")
	$UI/Loading.show()
	loading = $GeneratorSystem.generate()

func show_message(msg: String) -> void:
	$UI/Message/MarginContainer/MarginContainer/Label.text = msg
	$UI/Message.show()
	$TurnSystem.disabled = true

func append_message(msg: String) -> void:
	$UI/Message/MarginContainer/MarginContainer/Label.text += msg

func hide_message() -> void:
	$UI/Loading.hide()
	$UI/Message.hide()
	$TurnSystem.disabled = false
