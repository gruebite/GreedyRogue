extends Component
class_name Falling

const NAME := "Falling"

export var spawns: PackedScene
export var time := 4
export var damage := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var animated: Animated = entity.get_component(Animated.NAME)

func _ready() -> void:
	var _ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")

func _on_out_of_turn() -> void:
	time -= 1
	if animated:
		animated.frame += 1
	if time <= 0:
		var gpos := entity.grid_position
		var ents := entity_system.get_entities(gpos.x, gpos.y)
		for ent in ents:
			var health: Health = ent.get_component(Health.NAME)
			if health:
				health.health -= damage
		if spawns:
			entity_system.spawn_entity(spawns, entity.grid_position)
		entity.queue_free()
