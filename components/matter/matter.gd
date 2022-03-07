extends Component
class_name Matter

const NAME := "Matter"

enum {
	LAVA = 0x1,
	FIRE = 0x2,
}

export(int, FLAGS, "LAVA", "FIRE") var mask := 0
