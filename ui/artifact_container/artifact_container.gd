tool
extends TextureButton
class_name ArtifactContainer

enum Mode {
	UNSELECTED, ## Unselected
	SELECTED, ## Hovered by a mouse
	INPUT, ## Selected, and waiting for additional input (like direction)
}

export(Gradient) var input_gradient
export var mode: int = Mode.UNSELECTED setget set_mode
export var hide_charge := false
export var hide_level := false
export var always_selectabled := false

var selectable := true

var inputting := false

var artifact_name := ""

func _ready() -> void:
	if hide_charge:
		$MarginContainer/Foreground/DescriptionContainer/ChargeContainer.hide()
	if hide_level:
		$MarginContainer/Foreground/DescriptionContainer/Title/Level.hide()

func _process(_delta: float) -> void:
	if not inputting:
		return

	var p := (sin(OS.get_ticks_msec() / 100.0) + 1) * 0.5
	$NinePatchRect.modulate = input_gradient.interpolate(p)

func present_artifact(artifact: Artifact) -> void:
	artifact.get_component(Display.NAME).show()
	for c in $MarginContainer/Foreground/EntityContainer.get_children():
		c.queue_free()
	yield(get_tree(), "idle_frame")
	artifact_name = artifact.name
	$MarginContainer/Foreground/EntityContainer.add_child(artifact)

	selectable = not artifact.passive

	$MarginContainer/Foreground/DescriptionContainer/Title/Name.text = artifact.name
	$MarginContainer/Foreground/DescriptionContainer/Description.text = artifact.description
	update_artifact(artifact)

func update_artifact(artifact: Artifact) -> void:
	$MarginContainer/Foreground/DescriptionContainer/Title/Level.text = str("♦").repeat(artifact.level + 1)
	var cp := artifact.charge_p * 100.0
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = cp

func set_mode(m: int) -> void:
	if not selectable and not always_selectabled:
		return
	mode = m
	inputting = false
	match m:
		Mode.UNSELECTED:
			$NinePatchRect.modulate = Color.transparent
		Mode.SELECTED:
			$NinePatchRect.modulate = Palette.LIST[Palette.BROWN_7]
		Mode.INPUT:
			inputting = true
