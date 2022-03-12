extends Artifact

func _on_out_of_turn() -> void:
	var arts = backpack.get_artifacts()
	for art in arts:
		art.charge += int(ceil(self.max_charge * (level + 1) * 0.05))
