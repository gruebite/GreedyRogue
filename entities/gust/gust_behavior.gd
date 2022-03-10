extends Component
class_name GustBehavior

onready var display: Display = entity.get_component(Display.NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.get_component(Ignitable.NAME).connect("ignited", self, "_on_ignited")

func _on_ignited(_by: Entity) -> void:
	display.modulate = Palette.LIST[Palette.RED_1]
