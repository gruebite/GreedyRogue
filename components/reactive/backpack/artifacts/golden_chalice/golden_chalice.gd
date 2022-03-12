extends Artifact

var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		anxiety = backpack.entity.get_component(Anxiety.NAME)


func use(_dir: int) -> bool:
	anxiety.anxiety -= 100
	queue_free()
	return true
