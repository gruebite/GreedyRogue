extends Component
class_name Toppleable

const NAME := "Toppleable"

export(PackedScene) var spawns
export var height := 4

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")

func _on_bumped(by: Entity) -> void:
	var dv := entity.grid_position - by.grid_position
	for i in height:
		var desired: Vector2 = entity.grid_position + dv * i
		if tile_system.blocks_movement(desired.x, desired.y):
			break
		if spawns:
			entity_system.spawn_entity(spawns, desired)
	entity.kill(self)
