extends Button
class_name ArtifactContainer

export(Gradient) var input_gradient
export var hide_charge := false
export var hide_level := false
export var always_selectabled := false
export var hotkey := ""

var activated := false
var artifact_name := ""

func _ready() -> void:
	$MarginContainer/Foreground/VBoxContainer/Hotkey.text = hotkey
	update_artifact()

func _process(_delta: float) -> void:
	if not activated:
		$NinePatchRect.hide()
		return

	# 0.5 = TAU
	var y := (OS.get_ticks_msec() / 500.0) * TAU
	var p := (sin(y) + 1) * 0.5
	$NinePatchRect.modulate = input_gradient.interpolate(p)
	$NinePatchRect.show()

func get_artifact() -> Node2D:
	return $MarginContainer/Foreground/VBoxContainer/EntityContainer.get_child(0) as Node2D

func present_artifact(art_name: String) -> void:
	var artifact: Artifact = Artifacts.TABLE[art_name].instance()
	artifact.get_component(Display.NAME).brightness = Brightness.LIT
	artifact_name = art_name
	for c in $MarginContainer/Foreground/VBoxContainer/EntityContainer.get_children():
		c.queue_free()
	$MarginContainer/Foreground/VBoxContainer/EntityContainer.add_child(artifact)
	$MarginContainer/Foreground/VBoxContainer/EntityContainer.move_child(artifact, 0)

	disabled = artifact.passive and not always_selectabled

	$MarginContainer/Foreground/DescriptionContainer/Name.text = art_name
	$MarginContainer/Foreground/DescriptionContainer/Description.text = artifact.description
	update_artifact(artifact)

func update_artifact(artifact: Artifact=null) -> void:

	$MarginContainer/Foreground/VBoxContainer/Hotkey.show()
	$MarginContainer/Foreground/VBoxContainer/Level.show()
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.show()
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.show()

	if artifact:
		$MarginContainer/Foreground/VBoxContainer/Level.text = str("♦").repeat(artifact.level + 1)
		if artifact.consumed:
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.hide()
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/Label.text = "Consume"
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.modulate = Color(1, 1, 1, 1)
		elif artifact.passive:
			$MarginContainer/Foreground/VBoxContainer/Hotkey.hide()
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.hide()
		elif artifact.charge_p < 1:
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.modulate = Color(1, 1, 1, 0.5)
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/Label.text = "Charge"
		else:
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.modulate = Color(1, 1, 1, 1)
			$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/Label.text = "Charge"
		var cp := artifact.charge_p * 100.0
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = cp

	if hide_charge:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.hide()
	if hide_level:
		$MarginContainer/Foreground/VBoxContainer/Level.hide()
