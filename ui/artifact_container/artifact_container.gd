extends Button
class_name ArtifactContainer

export(Gradient) var input_gradient
export var hide_charge := false
export var hide_level := false
export var always_selectabled := false

var activated := false
var artifact_name := ""

func _ready() -> void:
	if hide_charge:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.hide()
	if hide_level:
		$MarginContainer/Foreground/DescriptionContainer/Title/Level.hide()

func _process(_delta: float) -> void:
	if not activated:
		$NinePatchRect.hide()
		return

	# 0.5 = TAU
	var y := (OS.get_ticks_msec() / 500.0) * TAU
	var p := (sin(y) + 1) * 0.5
	$NinePatchRect.modulate = input_gradient.interpolate(p)
	$NinePatchRect.show()

func present_artifact(art_name: String) -> void:
	var artifact: Artifact = Artifacts.TABLE[art_name].instance()
	artifact.get_component(Display.NAME).brightness = Brightness.LIT
	artifact_name = art_name
	for c in $MarginContainer/Foreground/EntityContainer.get_children():
		c.queue_free()
	$MarginContainer/Foreground/EntityContainer.add_child(artifact)

	disabled = artifact.passive and not always_selectabled

	$MarginContainer/Foreground/DescriptionContainer/Title/Name.text = art_name
	$MarginContainer/Foreground/DescriptionContainer/Description.text = artifact.description
	update_artifact(artifact)

func update_artifact(artifact: Artifact) -> void:
	$MarginContainer/Foreground/DescriptionContainer/Title/Level.text = str("♦").repeat(artifact.level + 1)
	if artifact.charge_p < 1 and not artifact.passive:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.modulate = Color(1, 1, 1, 0.5)
	else:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.modulate = Color(1, 1, 1, 1)
	var cp := artifact.charge_p * 100.0
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = cp
