extends Component
class_name EntityStack

const NAME := "EntityStack"

export(PackedScene) var spawns
export var height := 4
export var one_shot := true

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)

func _ready() -> void:
	var toppleable: Toppleable = entity.get_component(Toppleable.NAME)
	if toppleable:
		var _ignore = toppleable.connect("toppled", self, "_on_toppled")

func _on_toppled(by: Toppler) -> void:
	var dv := entity.grid_position - by.entity.grid_position
	for i in height:
		var desired: Vector2 = entity.grid_position + dv * i
		if tile_system.blocks_movement(desired.x, desired.y):
			break
		if spawns:
			entity_system.add_entity(spawns.instance(), desired)
	if one_shot:
		entity.kill("toppling over")
