extends Artifact

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	self.charge = 0
	return true
