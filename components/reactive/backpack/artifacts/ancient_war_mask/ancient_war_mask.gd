extends Artifact

var anxiety: Anxiety

func _ready() -> void:
	if backpack:
		anxiety = backpack.entity.get_component(Anxiety.NAME)
		var _ignore
		_ignore = backpack.entity.get_component(Attacker.NAME).connect("attacked", self, "_on_attacked")

func _on_attacked(_other: Attackable) -> void:
	anxiety.anxiety -= (level + 1) * 50
