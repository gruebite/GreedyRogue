extends Node2D
class_name Lair

const STAT_BLINKIING_THRESHOLD := 0.33

var loading = null
var game_over := false
var entered_level := false
var panicking := false

var gold_ps := 0.0

var name_regex := RegEx.new()

var player_health: Health
var player_anxiety: Anxiety

var turn_count := 0

func _ready() -> void:
	assert(name_regex.compile("([^@\\d]+)") == OK)
	var _ignore
	_ignore = $TurnSystem.connect("out_of_turn", self, "_turn_taken")
	_ignore = $TurnSystem.connect("canceled_turn", self, "_turn_taken")
	_ignore = $GeneratorSystem.connect("entered_level", self, "_on_entered_level")
	regenerate()

func _process(_delta: float) -> void:
	$UI/HUD/VBoxContainer/Info.text = ""
	# We're done loading.
	if not loading:
		if panicking:
			$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2(
				randf() * 5 - 2.5, randf() * 5 - 2.5)
		else:
			$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2.ZERO

		var dt: float = (OS.get_ticks_msec() / 1000.0) * 20
		if player_health.health_p <= STAT_BLINKIING_THRESHOLD:
			$UI/HUD/VBoxContainer/Health/Value/Progress.modulate = Color.white.linear_interpolate(Color.transparent, sin(dt))
		else:
			$UI/HUD/VBoxContainer/Health/Value/Progress.modulate = Color.white
		if player_anxiety.anxiety_p >= 1 - STAT_BLINKIING_THRESHOLD:
			$UI/HUD/VBoxContainer/Anxiety/Value/Progress.modulate = Color.white.linear_interpolate(Color.transparent, sin(dt))
		else:
			$UI/HUD/VBoxContainer/Anxiety/Value/Progress.modulate = Color.white


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
			$UI/HUD/VBoxContainer/Info.text = top.id
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

	# We just finished loading.
	if not loading:
		hide_message()
		$UI/WashedOut.hide()
		var player = $EntitySystem.player
		if $GeneratorSystem.generated_level == 0:
			var _ignore
			_ignore = player.connect("died", self, "_on_player_died")
			_ignore = player.get_component(Backpack.NAME).connect("gained_artifact", self, "_on_gained_artifact")
			_ignore = player.get_component(Backpack.NAME).connect("artifact_level_changed", self, "_on_artifact_level_changed")
			_ignore = player.get_component(Backpack.NAME).connect("artifact_charge_changed", self, "_on_artifact_charge_changed")
			_ignore = player.get_component(Backpack.NAME).connect("picked_up_gold", self, "_on_picked_up_gold")
			_ignore = player.get_component(Backpack.NAME).connect("picked_up_treasure", self, "_on_picked_up_treasure")
			player_health = player.get_component(Health.NAME)
			_ignore = player_health.connect("health_changed", self, "_on_health_changed")
			player_anxiety = player.get_component(Anxiety.NAME)
			_ignore = player_anxiety.connect("anxiety_changed", self, "_on_anxiety_changed")
			_ignore = player_anxiety.connect("panicking", self, "_on_panicking")
			_ignore = player_anxiety.connect("calmed_down", self, "_on_calmed_down")
			_ignore = player.get_component(Controller.NAME).connect("found_exit", self, "_on_found_exit")
			_ignore = player.get_component(Controller.NAME).connect("activated_artifact", self, "_on_activated_artifact")
			_ignore = player.get_component(Controller.NAME).connect("deactivated_artifact", self, "_on_deactivated_artifact")
			var treasures := $UI/HUD/VBoxContainer/Treasures
			for t in treasures.get_children():
				t.hide()
			# Kinda hacky.
			_on_health_changed(1, 1)
			_on_anxiety_changed(0, 1)
			gold_ps = 0.0
			update_gold()
		else:
			update_gold()
		show_message(GeneratorSystem.LEVEL_MESSAGES[$GeneratorSystem.generated_level],
			GeneratorSystem.LEVEL_TITLES[$GeneratorSystem.generated_level], true, true)
		$HoardSystem.debug_gold()

func _input(event: InputEvent) -> void:
	if not $UI/Message.visible:
		return
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			hide_message()
			if game_over:
				regenerate()
			elif entered_level:
				$EffectSystem.add_effect(preload("res://effects/ping/ping.tscn"), $EntitySystem.player.grid_position)
	if event is InputEventMouseButton:
		if event.pressed:
			hide_message()
			if game_over:
				regenerate()
			elif entered_level:
				$EffectSystem.add_effect(preload("res://effects/ping/ping.tscn"), $EntitySystem.player.grid_position)

func _turn_taken() -> void:
	turn_count += 1

func _on_entered_level(_lvl: int) -> void:
	entered_level = true

func _on_player_died(source: String) -> void:
	var total_gold_p: float = ((gold_ps + $HoardSystem.gold_p) / ($GeneratorSystem.generated_level + 1)) * 100.0

	# Easter egg.
	var one_ring: bool = $EntitySystem.player.get_component(Backpack.NAME).has_artifact("Ring of Power")
	var ppos: Vector2 = $EntitySystem.player.grid_position
	if one_ring and $NavigationSystem.is_lava(ppos.x, ppos.y):
		show_message("Collected %.0f%% of the gold" % [total_gold_p],
			"Destroyed the One Ring!", true, true)
	else:
		show_message("Collected %.0f%% of the gold" % [total_gold_p],
			"Died from %s" % [source], true, true)
	game_over = true


func _on_picked_up_gold() -> void:
	$HoardSystem.collect_gold()
	update_gold()

func _on_picked_up_treasure() -> void:
	var arts = Artifacts.random_artifacts($EntitySystem.player.get_component(Backpack.NAME))
	pick_artifact(arts)

func _on_gained_artifact(artifact: Artifact) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			t.present_artifact(artifact.id)
			t.show()
			break

func _on_artifact_level_changed(artifact: Artifact, _to: int, _mx: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			break
		if t.artifact_name == artifact.id:
			t.update_artifact(artifact)
			break

func _on_artifact_charge_changed(artifact: Artifact, _to: int, _mx: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	for i in treasures.get_child_count():
		var t := treasures.get_child(i)
		if not t.visible:
			break
		if t.artifact_name == artifact.id:
			t.update_artifact(artifact)
			break

func _on_health_changed(to: int, mx: int) -> void:
	$UI/HUD/DamageAnimation.play("shake")
	$UI/HUD/VBoxContainer/Health/Value/Progress.value = (float(to) / mx) * 100

func _on_anxiety_changed(to: int, mx: int) -> void:
	$UI/HUD/VBoxContainer/Anxiety/Value/Progress.value = (float(to)) / mx * 100

func _on_panicking(_amount: int) -> void:
	panicking = true

func _on_calmed_down() -> void:
	panicking = false
	$UI/HUD/VBoxContainer/Anxiety/Value/Progress.rect_position = Vector2.ZERO

func _on_found_exit() -> void:
	gold_ps += $HoardSystem.gold_p
	var lvl: int = $GeneratorSystem.generated_level
	if lvl == GeneratorSystem.LEVEL_COUNT - 1:
		var total_gold_ps: float = gold_ps / GeneratorSystem.LEVEL_COUNT
		show_message("Collected %.2f%% of the gold" % (total_gold_ps * 100),
			"Made it out alive!", true, true)
		game_over = true
	else:
		regenerate(lvl + 1, true)

func _on_use_artifact(index: int) -> void:
	$EntitySystem.player.get_component(Controller.NAME).use_artifact(index)

func _on_activated_artifact(index: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	treasures.get_child(index).activated = true

func _on_deactivated_artifact(index: int) -> void:
	var treasures := $UI/HUD/VBoxContainer/Treasures
	treasures.get_child(index).activated = false

func update_gold() -> void:
	var total_gold_p: float = ((gold_ps + $HoardSystem.gold_p) / ($GeneratorSystem.generated_level + 1)) * 100.0
	print("Gold percentage: %0.2f%%" % [total_gold_p])
	$UI/HUD/VBoxContainer/Gold/Value.text = "%.0f%%" % [total_gold_p]

func regenerate(level: int=0, keep_player: bool=false) -> void:
	print("Turns taken: " + str(turn_count))
	entered_level = false
	turn_count = 0
	game_over = false
	show_message("Loading")
	$UI/WashedOut.show()
	loading = $GeneratorSystem.generate(level, keep_player)

func show_message(msg: String, title: String="", border: bool=false, hint: bool=false) -> void:
	$UI/Message/MarginContainer/MarginContainer/VBoxContainer/Label.text = msg
	$UI/Message/MarginContainer/MarginContainer/VBoxContainer/Title.text = title
	if border:
		$UI/Message/MarginContainer/Border.show()
	else:
		$UI/Message/MarginContainer/Border.hide()
	if hint:
		$UI/Message/MarginContainer/MarginContainer/VBoxContainer/Hint.show()
	else:
		$UI/Message/MarginContainer/MarginContainer/VBoxContainer/Hint.hide()
	$UI/Message.show()
	$TurnSystem.disabled = true

func append_message(msg: String) -> void:
	$UI/Message/MarginContainer/MarginContainer/VBoxContainer/Label.text += msg

func hide_message() -> void:
	$UI/WashedOut.hide()
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
