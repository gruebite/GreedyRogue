extends Component
class_name Matter

const NAME := "Matter"

enum {
	LAVA = 0x1,
	FIRE = 0x2,
	GOLD = 0x4,
}

export(int, FLAGS, "LAVA", "FIRE", "GOLD") var mask := 0
