extends Component
class_name Matter

const NAME := "Matter"

enum {
	LAVA = 0x1,
	FIRE = 0x2,
	GOLD = 0x4,
	WIND = 0x8,
}

export(int, FLAGS, "LAVA", "FIRE", "GOLD", "WIND") var mask := 0
