extends Component
class_name Terrorize

const NAME := "Terrorize"

export var terror := 2

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

onready var player_anxiety: Anxiety = entity_system.player.get_component(Anxiety.NAME)

func _ready() -> void:
	var _ignore
	_ignore = entity.get_component(Elemental.NAME).connect("pursuing", self, "_on_pursuing")

func _on_pursuing() -> void:
	player_anxiety.panic = terror
