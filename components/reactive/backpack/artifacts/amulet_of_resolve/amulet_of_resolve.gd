extends Artifact

var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		var _ignore
		anxiety = backpack.entity.get_component(Anxiety.NAME)
		_ignore = anxiety.connect("mindful", self, "_on_mindful")

func _on_mindful() -> void:
	if anxiety.panic > anxiety.normal_panic:
		anxiety.panic *= -1
