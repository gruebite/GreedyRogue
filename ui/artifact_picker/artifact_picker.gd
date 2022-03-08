extends CenterContainer

const NEW := "New! "
const UPGRADE := "Upgrade "
const CONSUMED := "Consume "

signal picked(index)

onready var artifact_picks := [
	$Panel/MarginContainer/VBoxContainer/Artifacts/ArtifactContainer1,
	$Panel/MarginContainer/VBoxContainer/Artifacts/ArtifactContainer2,
	$Panel/MarginContainer/VBoxContainer/Artifacts/ArtifactContainer3,
]
onready var artifact_actions := [
	$Panel/MarginContainer/VBoxContainer/Actions/Action1,
	$Panel/MarginContainer/VBoxContainer/Actions/Action2,
	$Panel/MarginContainer/VBoxContainer/Actions/Action3,
]

func present_picks(arts: Array) -> void:
	for i in 3:
		artifact_picks[i].update_artifact(Artifacts.TABLE[arts[i]].instance())

func level_picks(lvls: Array) -> void:
	for i in 3:
		if lvls[i] == -1:
			artifact_actions[i].text = CONSUMED + "[" + str(i + 1) + "]"
		elif lvls[i] == 0:
			artifact_actions[i].text = NEW + "[" + str(i + 1) + "]"
		else:
			artifact_actions[i].text = UPGRADE + "[" + str(i + 1) + "]"

func _on_action_pressed(index: int) -> void:
	var art_name: String = "" if index == -1 else artifact_picks[index].artifact_name
	emit_signal("picked", art_name)

func _on_considering(index: int) -> void:
	artifact_picks[index].mode = ArtifactContainer.Mode.SELECTED
	artifact_actions[index].toggle_mode = true
	artifact_actions[index].set_pressed_no_signal(true)

func _on_unconsidering(index: int) -> void:
	artifact_picks[index].mode = ArtifactContainer.Mode.UNSELECTED
	artifact_actions[index].set_pressed_no_signal(false)
	artifact_actions[index].toggle_mode = false
