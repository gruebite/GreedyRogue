extends Artifact

var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		var _ignore
		_ignore = anxiety.connect("panicking", self, "_on_panicking")

func _on_panicking(amount: int) -> void:
	anxiety.panic = -amount * level
