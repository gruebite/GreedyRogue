extends Artifact

var effect_system: EffectSystem

var anxiety: Anxiety
var bright: Bright
var display: Display

var invisible_timer := 0

func _ready() -> void:
	if backpack:
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)

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
	effect_system.add_effect(preload("res://effects/spell_cast/spell_cast.tscn"), backpack.entity.grid_position)
	return false
