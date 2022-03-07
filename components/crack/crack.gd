extends Component
class_name Crack

const NAME := "Crack"

export var integrity := 3

onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)

onready var animated: Animated = entity.get_component(Animated.NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Tripwire.NAME).connect("tripped", self, "_on_tripped")

func _on_tripped(by: Entity) -> void:
	integrity -= 1
	if animated:
		animated.frame += 1
	if integrity <= 0:
		by.queue_free()
		entity.kill(self)
		var gpos := entity.grid_position
		tile_system.set_tile(gpos.x, gpos.y, Tile.CHASM)

