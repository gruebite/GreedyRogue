extends Component
class_name Crack

const NAME := "Crack"

export var integrity := 3

onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)

onready var animated: Animated = entity.get_component(Animated.NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Trippable.NAME).connect("tripped", self, "_on_tripped")

func _on_tripped(by: Entity) -> void:
	integrity -= 1
	if animated:
		animated.frame += 1
		effect_system.add_effect(preload("res://effects/cracking/cracking.tscn").instance(), entity.position)
	if integrity <= 0:
		var gpos := entity.grid_position
		tile_system.set_tile(gpos.x, gpos.y, Tile.CHASM)
		by.kill(self)
		entity.kill(self)
