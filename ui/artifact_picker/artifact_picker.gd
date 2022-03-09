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
		artifact_picks[i].present_artifact(arts[i])

func level_picks(lvls: Array) -> void:
	for i in 3:
		if lvls[i] == -1:
			artifact_actions[i].text = CONSUMED + "[" + str(i + 1) + "]"
		elif lvls[i] == 0:
			artifact_actions[i].text = NEW + "[" + str(i + 1) + "]"
		else:
			artifact_actions[i].text = UPGRADE + "[" + str(i + 1) + "]"

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_action_pressed(-1)
		accept_event()
	elif event.is_action_pressed("ui_1"):
		_on_action_pressed(0)
		accept_event()
	elif event.is_action_pressed("ui_2"):
		_on_action_pressed(1)
		accept_event()
	elif event.is_action_pressed("ui_3"):
		_on_action_pressed(2)
		accept_event()

func _on_action_pressed(index: int) -> void:
	var art_name: String = "" if index == -1 else artifact_picks[index].artifact_name
	emit_signal("picked", art_name)

func _on_considering(index: int) -> void:
	artifact_picks[index].toggle_mode = true
	artifact_picks[index].set_pressed_no_signal(true)
	artifact_actions[index].toggle_mode = true
	artifact_actions[index].set_pressed_no_signal(true)

func _on_unconsidering(index: int) -> void:
	artifact_picks[index].set_pressed_no_signal(false)
	artifact_picks[index].toggle_mode = false
	artifact_actions[index].set_pressed_no_signal(false)
	artifact_actions[index].toggle_mode = false
