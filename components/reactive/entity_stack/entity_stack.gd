extends Component
class_name EntityStack

const NAME := "EntityStack"

export(PackedScene) var spawns
export var height := 4
export var one_shot := true

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var bumpable: Bumpable = entity.get_component(Bumpable.NAME)
	if bumpable:
		var _ignore = bumpable.connect("bumped", self, "_on_bumped")

func _on_bumped(by: Bumper) -> void:
	var dv := entity.grid_position - by.entity.grid_position
	for i in height:
		var desired: Vector2 = entity.grid_position + dv * i
		if navigation_system.out_of_bounds(desired.x, desired.y):
			continue
		if tile_system.blocks_movement(desired.x, desired.y):
			continue
		if spawns:
			entity_system.add_entity(spawns.instance(), desired)
	if one_shot:
		entity.kill("toppled")
