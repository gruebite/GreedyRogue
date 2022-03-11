extends Artifact

var anxiety: Anxiety
var bright: Bright
var display: Display

var invisible_timer := 0

func _ready() -> void:
	if backpack:
		anxiety = backpack.entity.get_component(Anxiety.NAME)
		bright = backpack.entity.get_component(Bright.NAME)
		display = backpack.entity.get_component(Display.NAME)

func _on_initiated_turn() -> void:
	if invisible_timer > 0:
		invisible_timer -= 1
		anxiety.anxiety += 1
		bright.disabled = true
		display.force_brightness = Brightness.DIM
	else:
		self.charge += 1
		bright.disabled = false
		display.force_brightness = -1

func use(_dir: int) -> bool:
	invisible_timer = 20
	self.charge = 0
	return false
