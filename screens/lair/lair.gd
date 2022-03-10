extends Node2D
class_name Lair

var loading = null
var game_over := false
var panicking := false

var name_regex := RegEx.new()

func _ready() -> void:
	assert(name_regex.compile("([^@\\d]+)") == OK)
	regenerate()

func _process(_delta: float) -> void:
	if panicking:
		$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2(
			randf() * 5 - 2.5, randf() * 5 - 2.5)

	$UI/HUD/VBoxContainer/Info.text = ""
	if not loading:
		# We have a menu up or something.
		if $TurnSystem.disabled:
			return
		var mouse_pos := get_global_mouse_position()
		if not Rect2(Vector2.ZERO, Constants.MAP_RESOLUTION).has_point(mouse_pos):
			return
		var mouse_grid_pos := (mouse_pos / Constants.CELL_VECTOR).floor()
		if $BrightSystem.get_brightness(mouse_grid_pos.x, mouse_grid_pos.y) <= Brightness.DIM:
			return
		var top: Entity = $EntitySystem.get_first_top_entity(mouse_grid_pos.x, mouse_grid_pos.y)
		if top:
			$UI/HUD/VBoxContainer/Info.text = name_regex.search(top.name).get_string()
		else:
			match $TileSystem.get_tile(mouse_grid_pos.x, mouse_grid_pos.y):
				Tile.WALL:
					$UI/HUD/VBoxContainer/Info.text = "Wall"
				Tile.EXIT:
					$UI/HUD/VBoxContainer/Info.text = "Exit"
				_:
					$UI/HUD/VBoxContainer/Info.text = "Floor"
		return

	if loading is GDScriptFunctionState and loading.is_valid():
		loading = loading.resume()
		append_message(".")

	if not loading:
		hide_message()
		$UI/Loading.hide()
		var player = $EntitySystem.player
		var _ignore
		_ignore = player.connect("died", self, "_on_player_died")
		_ignore = player.get_component(Backpack.NAME).connect("gold_changed", self, "_on_gold_changed")
		_ignore = player.get_component(Backpack.NAME).connect("gained_artifact", self, "_on_gained_artifact")
		_ignore = player.get_component(Backpack.NAME).connect("artifact_level_changed", self, "_on_artifact_level_changed")
		_ignore = player.get_component(Backpack.NAME).connect("artifact_charge_changed", self, "_on_artifact_charge_changed")
		_ignore = player.get_component(Health.NAME).connect("health_changed", self, "_on_health_changed")
		_ignore = player.get_component(Anxiety.NAME).connect("anxiety_changed", self, "_on_anxiety_changed")
		_ignore = player.get_component(Anxiety.NAME).connect("panicking", self, "_on_panicking")
		_ignore = player.get_component(Anxiety.NAME).connect("calmed_down", self, "_on_calmed_down")
		_ignore = player.get_component(Backpack.NAME).connect("picked_up_gold", self, "_on_picked_up_gold")
		_ignore = player.get_component(Backpack.NAME).connect("picked_up_treasure", self, "_on_picked_up_treasure")
		_ignore = player.get_component(Controller.NAME).connect("found_exit", self, "_on_found_exit")
		_ignore = player.get_component(Controller.NAME).connect("activated_artifact", self, "_on_activated_artifact")
		_ignore = player.get_component(Controller.NAME).connect("deactivated_artifact", self, "_on_deactivated_artifact")
		# Kinda hacky.
		_on_health_changed(1, 1)
		_on_anxiety_changed(0, 1)
		_on_gold_changed(0)

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
	show_message("Died\nCollected %.2f%% of the gold" % [$HoardSystem.gold_p * 100])
	game_over = true

func _on_gold_changed(to: int) -> void:
	print("Gold percentage: %0.2f%%" % [$HoardSystem.gold_p * 100])
	$UI/HUD/VBoxContainer/Gold/Value.text = str(to)

func _on_gained_artifact(artifact: Artifact) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			t.present_artifact(artifact.name)
			t.show()
			break

func _on_artifact_level_changed(artifact: Artifact, _to: int, _mx: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			break
		if t.artifact_name == artifact.name:
			t.update_artifact(artifact)
			break

func _on_artifact_charge_changed(artifact: Artifact, _to: int, _mx: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			break
		if t.artifact_name == artifact.name:
			t.update_artifact(artifact)
			break

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
	if $HoardSystem.gold_p < 0.5:
		show_message("Refuse to leave with less than 50%% of the gold\nCollected %.2f%%" % ($HoardSystem.gold_p * 100))
		return
	show_message("Found an escape!\nCollected %.2f%% of the gold" % ($HoardSystem.gold_p * 100))
	game_over = true

func _on_picked_up_gold() -> void:
	$HoardSystem.collect_gold()

func _on_picked_up_treasure() -> void:
	var arts = Artifacts.random_treasures($EntitySystem.player.get_component(Backpack.NAME))
	pick_artifact(arts)

func _on_use_artifact(index: int) -> void:
	$EntitySystem.player.get_component(Controller.NAME).use_artifact(index)

func _on_activated_artifact(index: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	treasures.get_child(index).activated = true

func _on_deactivated_artifact(index: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	treasures.get_child(index).activated = false

func regenerate() -> void:
	game_over = false
	show_message("Loading")
	$UI/Loading.show()

	var treasures := $UI/HUD/VBoxContainer/Treasures
	for t in treasures.get_children():
		t.hide()
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

func pick_artifact(arts: Array) -> void:
	var backpack: Backpack = $EntitySystem.player.get_component(Backpack.NAME)
	$UI/ArtifactPicker.show()
	$UI/ArtifactPicker.grab_focus()
	$UI/ArtifactPicker.present_picks(arts)
	var lvls := []
	for i in 3:
		var cons: bool = arts[i] in Artifacts.CONSUMED
		# TODO: Get current level from backpack.
		var lvl := -1 if cons else (backpack.artifact_level(arts[i]) + 1)
		lvls.append(lvl)
	$UI/ArtifactPicker.level_picks(lvls)
	$TurnSystem.disabled = true

func done_picking() -> void:
	$UI/ArtifactPicker.hide()
	$TurnSystem.disabled = false

func _on_artifact_picked(n: String) -> void:
	done_picking()
	if n == "":
		return
	var backpack: Backpack = $EntitySystem.player.get_component(Backpack.NAME)
	backpack.add_artifact(n)
