extends Artifact

func use(_dir: int) -> bool:
	for art in backpack.get_artifacts():
		art.level += 1
	queue_free()
	return false
