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

var gold: int
var item: int

func initialize():
	gold = randi() % (max_gold - min_gold + 1) + min_gold
	item = Item.NONE
	return self
