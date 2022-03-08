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

func update_artifact(artifact: Artifact, duplicate: bool=false) -> void:
	var own := artifact.duplicate() if duplicate else artifact
	own.get_component(Display.NAME).show()
	for c in $MarginContainer/Foreground/EntityContainer.get_children():
		c.queue_free()
	yield(get_tree(), "idle_frame")
	artifact_name = own.name
	$MarginContainer/Foreground/EntityContainer.add_child(own)

	var _ignore
	_ignore = own.connect("level_changed", self, "_on_level_chaned")
	_ignore = own.connect("charge_changed", self, "_on_charge_chaned")

	selectable = not own.passive

	$MarginContainer/Foreground/DescriptionContainer/Title/Name.text = own.name
	$MarginContainer/Foreground/DescriptionContainer/Title/Level.text = str("♦").repeat(own.level + 1)
	$MarginContainer/Foreground/DescriptionContainer/Description.text = own.description
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = 100.0

func _on_level_changed(to: int) -> void:
	$MarginContainer/Foreground/DescriptionContainer/Title/Level.text = str(to)

func _on_charge_changed() -> void:
	$MarginContainer/Foreground/DescriptionContainer/ChargeContainer/TextureProgress.value = 100.0

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
