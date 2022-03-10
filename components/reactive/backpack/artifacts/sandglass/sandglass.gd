extends Artifact

var controller

func _ready() -> void:
	if backpack:
		controller = backpack.entity.get_component("Controller")

func _on_take_turn() -> void:
	self.charge += 1

func use(_dir) -> bool:
	controller.skip_turns = (level + 1) * 5
	self.charge = 0
	return true
