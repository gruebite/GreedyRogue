extends Component
class_name Treasure

const NAME := "Treasure"

enum Item {
	NONE,
	TORCH,
	POTION,
}

export var min_gold := 0
export var max_gold := 0

export var torch_weight := 0.0
export var potion_weight := 0.0

onready var hoard_system: HoardSystem = find_system(HoardSystem.GROUP_NAME)

onready var gold: int = randi() % (max_gold - min_gold + 1) + min_gold
onready var item: int = Item.NONE

func _ready() -> void:
	hoard_system.add_treasure(self)

func _exit_tree() -> void:
	hoard_system.remove_treasure(self)
