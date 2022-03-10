extends Component
class_name GolemBehavior

const NAME := "GolemBehavior"

onready var display: Display = entity.get_component(Display.NAME)
onready var elemental: Elemental = entity.get_component(Elemental.NAME)

func _ready() -> void:
	var _ignore
	_ignore = elemental.connect("idling", self, "_on_idling")
	_ignore = elemental.connect("pursuing", self, "_on_pursuing")

func _on_idling() -> void:
	display.frame = 0

func _on_pursuing() -> void:
	display.frame = 1
