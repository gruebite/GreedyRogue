extends Component
class_name Faller

const NAME := "Faller"

export var immune := false

onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = find_system(TurnSystem.GROUP_NAME).connect("taken_turns", self, "_on_taken_turns")

func _on_taken_turns() -> void:
	if immune:
		return
	var gpos := entity.grid_position
	if tile_system.get_tile(gpos.x, gpos.y) == Tile.CHASM:
		entity.kill("falling into a chasm")
