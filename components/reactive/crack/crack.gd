extends Component
class_name Crack

const NAME := "Crack"

export var integrity := 3

onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)

onready var display: Display = entity.get_component(Display.NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Trippable.NAME).connect("tripped", self, "_on_tripped")

func _on_tripped(_by: Tripper) -> void:
	integrity -= 1
	if display:
		display.frame += 1
		effect_system.add_effect(preload("res://effects/cracking/cracking.tscn"), entity.grid_position)
	if integrity <= 0:
		var gpos := entity.grid_position
		tile_system.set_tile(gpos.x, gpos.y, Tile.CHASM)
		entity.kill("breaking")
