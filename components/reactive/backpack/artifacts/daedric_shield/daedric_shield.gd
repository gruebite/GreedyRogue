extends Artifact

func _ready() -> void:
	if backpack:
		backpack.entity.get_component(Knockbackable.NAME).immune = true

func _on_out_of_turn() -> void:
	backpack.entity.get_component(Attackable.NAME).resistance = level + 1
