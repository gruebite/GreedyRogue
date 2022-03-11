extends Artifact

var controller

func _ready() -> void:
	if backpack:
		controller = backpack.entity.get_component("Controller")

func _on_out_of_turn() -> void:
	self.charge += 1

func use(_dir) -> bool:
	controller.skip_turns = (level + 1) * 2
	self.charge = 0
	return true
