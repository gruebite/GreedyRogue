extends Component
class_name Toppleable

const NAME := "Toppleable"

export var height := 4

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")

func _on_bumped(by: Entity) -> void:
	var dv := entity.grid_position - by.grid_position
	for i in height:
		var desired: Vector2 = entity.grid_position + dv * (i + 1)
		if tile_system.blocks_movement(desired.x, desired.y):
			break
		entity_system.spawn_entity(preload("res://entities/falling_rock/falling_rock.tscn"), desired)
	entity.kill(self)
