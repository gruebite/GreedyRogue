extends Node2D

const WIDTH := 1280 / 2
const HEIGHT := 720 / 2
const COLS := WIDTH / 8
const ROWS := HEIGHT / 8

enum {
	WALL,
	FLOOR,
	PLAYER,
}

enum {
	UNLIT,
	LIT,
	DIM,
}

enum {
	WHITE, RED, GREEN, BLUE, YELLOW, MAGENTA, CYAN, GRAY,
	BROWN,
}

var px := COLS / 2
var py := ROWS / 2
var ptile = FLOOR

var trans_grid := DenseGrid.new(COLS, ROWS)
var light_grid := DenseGrid.new(COLS, ROWS)

func mark_shrinking_room(walker: Walker) -> bool:
	var params = [
		walker.rng.randi_range(1, 4),
		walker.rng.randi_range(1, 4),
		walker.rng.randi_range(1, 4),
		walker.rng.randi_range(1, 4)]
	while true:
		var count_0s := 0
		for p in params:
			if p == 0: count_0s += 1
		# Shrank too much.
		if count_0s == 3:
			return false

		var ps := PointSets.rectangle(params[0], params[1], params[2], params[3])
		if walker.check_point_set(ps, Walker.CHECK_OPENED_ALL):
			walker.mark_point_set(ps, FLOOR)
			return true

		var idx := walker.rng.randi_range(0, 3)
		while params[idx] == 0:
			idx = (idx + 1) % 4
		params[idx] -= 1
	return true

func _ready() -> void:
	Cp437._print()
	var walker := Walker.new()
	walker.start(COLS, ROWS)
	walker.goto(COLS / 2, ROWS / 2)
	walker.mark(FLOOR)
	walker.commit()

	var retries := 1000
	while walker.percent_opened() < 0.8 and retries > 0:
		walker.goto_random_opened()
		walker.remember()
		walker.goto_random_closed()
		var hfirst = walker.rng.randi_range(1, 2) == 1
		if mark_shrinking_room(walker):
			while not walker.is_on_opened():
				walker.step_corridor_last_remembered(hfirst)
				walker.mark(FLOOR)
		else:
			retries -= 1
		walker.forget()
		walker.commit()

	for x in COLS:
		for y in ROWS:
			var tile := walker.get_tile(x, y)
			match tile:
				WALL:
					$Tiles.set_tile(x, y, tile, BROWN)
					trans_grid.set_cell(x, y, Fov.Transparency.NONE)
				FLOOR:
					$Tiles.set_tile(x, y, tile, GRAY)
					trans_grid.set_cell(x, y, Fov.Transparency.FULL)
	$Tiles.set_tile(px, py, PLAYER, RED)
	update_fog()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		$Tiles.set_tile(px, py, ptile, GRAY)
		match event.scancode:
			KEY_UP:
				if $Tiles.get_tile(px, py - 1) != WALL:
					py -= 1
			KEY_DOWN:
				if $Tiles.get_tile(px, py + 1) != WALL:
					py += 1
			KEY_LEFT:
				if $Tiles.get_tile(px - 1, py) != WALL:
					px -= 1
			KEY_RIGHT:
				if $Tiles.get_tile(px + 1, py) != WALL:
					px += 1
			KEY_SPACE:
				$TurnSystem.initiate_turn()
		$Tiles.set_tile(px, py, PLAYER, RED)
		update_fog()

func update_fog() -> void:
	light_grid.clear()
	ShadowCast.compute(trans_grid, light_grid, Vector2(px, py), 17)
	for x in COLS:
		for y in ROWS:
			var color: int = $Fog.get_color(x, y)
			if color == -1:
				color = UNLIT
				$Fog.set_tile(x, y, 16, UNLIT)
			if light_grid.get_cell(x, y) == LIT:
				match color:
					UNLIT:
						$Fog.set_tile(x, y, 16, LIT)
					DIM:
						$Fog.set_tile(x, y, 16, LIT)
			else:
				match color:
					LIT:
						$Fog.set_tile(x, y, 16, DIM)
