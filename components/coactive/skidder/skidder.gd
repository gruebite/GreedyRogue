extends Component
class_name Skidder

const NAME := "Skidder"

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.connect("moved", self, "_on_moved")

func _on_moved(from: Vector2) -> void:
	var gpos := entity.grid_position
	var dv := gpos - from
	dv.x = sign(dv.x)
	dv.y = sign(dv.y)
	var slippables := entity_system.get_components(gpos.x, gpos.y, Slippable.NAME)
	if slippables.size() > 0:
		var newpos := gpos + dv
		if navigation_system.can_move_to(entity, newpos):
			navigation_system.move_to(entity, newpos)
			effect_system.add_effect(
				preload("res://effects/splash/splash.tscn"),
				gpos, Palette.BROWN_4)

