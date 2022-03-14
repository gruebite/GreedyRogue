extends Component
class_name GustBehavior

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var display: Display = entity.get_component(Display.NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.get_component(Ignites.NAME).connect("ignited", self, "_on_ignited")
	_ignore = turn_system.connect("initiated_turn", self, "_on_initiated_turn")

func _on_ignited(_by: Flaming) -> void:
	display.modulate = Palette.LIST[Palette.RED_1]

func _on_initiated_turn() -> void:
	display.frame += 1
	if display.frame > 3:
		display.frame = 3
