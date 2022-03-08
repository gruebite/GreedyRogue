extends Button
class_name ArtifactContainer

export(Gradient) var input_gradient
export var hide_charge := false
export var hide_level := false
export var always_selectabled := false

var artifact_name := ""

func _ready() -> void:
	if hide_charge:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.hide()
	if hide_level:
		$MarginContainer/Foreground/DescriptionContainer/Title/Level.hide()

func present_artifact(artifact: Artifact) -> void:
	artifact.get_component(Display.NAME).show()
	for c in $MarginContainer/Foreground/EntityContainer.get_children():
		c.queue_free()
	yield(get_tree(), "idle_frame")
	artifact_name = artifact.name
	$MarginContainer/Foreground/EntityContainer.add_child(artifact)

	disabled = artifact.passive and not always_selectabled

	$MarginContainer/Foreground/DescriptionContainer/Title/Name.text = artifact.name
	$MarginContainer/Foreground/DescriptionContainer/Description.text = artifact.description
	update_artifact(artifact)

func update_artifact(artifact: Artifact) -> void:
	$MarginContainer/Foreground/DescriptionContainer/Title/Level.text = str("♦").repeat(artifact.level + 1)
	var cp := artifact.charge_p * 100.0
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = cp
