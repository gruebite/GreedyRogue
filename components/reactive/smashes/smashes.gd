extends Component

export var smashes_left := 3

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var moves: Moves = entity.get_component(Moves.NAME)

func _ready() -> void:
	var _ignore = moves.connect("move_failed", self, "_on_move_failed")

func _on_move_failed(_to: Vector2) -> void:
	smashes_left -= 1
	if smashes_left <= 0:
		entity.kill("smashed")
		var _ignore = entity_system.spawn_entity(preload("res://entities/mud/mud.tscn"), entity.grid_position)
	else:
		effect_system.add_effect(
			preload("res://effects/splash/splash.tscn"),
			entity.grid_position, Palette.BROWN_4)
