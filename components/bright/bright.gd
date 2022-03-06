extends Component
class_name Bright

const NAME := "Bright"

export var lit_radius := 1
export var dim_radius := 3

onready var bright_system: BrightSystem = find_system(BrightSystem.GROUP_NAME)

func _ready() -> void:
	bright_system.add_bright(self)
	
func _exit_tree() -> void:
	bright_system.remove_bright(self)
