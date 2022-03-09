extends Component
class_name Bright

const NAME := "Bright"

export var dynamic := false

export var dim_radius := 3 setget , get_dim_radius
export var lit_radius := 1 setget , get_lit_radius

onready var bright_system: BrightSystem = find_system(BrightSystem.GROUP_NAME)

var glow_dim := 0
var glow_lit := 0

func _ready() -> void:
	bright_system.register_bright(self)

func _exit_tree() -> void:
	bright_system.unregister_bright(self)

func glow(dim: int, lit: int) -> void:
	glow_dim = dim
	glow_lit = lit

func unglow() -> void:
	glow_dim = 0
	glow_lit = 0

func get_dim_radius() -> int:
	return glow_dim + dim_radius

func get_lit_radius() -> int:
	return glow_lit + lit_radius
