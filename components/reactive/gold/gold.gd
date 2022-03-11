extends Component
class_name Gold

const NAME := "Gold"

onready var hoard_system: HoardSystem = find_system(HoardSystem.GROUP_NAME)

func _ready() -> void:
	hoard_system.add_gold(self)

func _exit_tree() -> void:
	hoard_system.remove_gold(self)
