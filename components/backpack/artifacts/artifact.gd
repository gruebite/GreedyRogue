extends Entity
class_name Artifact

const GROUP_NAME := "artifact"

signal level_changed(to, mx)
signal charge_changed(to, mx)

export(String, MULTILINE) var description := ""
export(PoolIntArray) var max_charges := [0]
export var consumed := false
export var passive := false

export var level: int = 0 setget set_level
export var charge: int = 0 setget set_charge
var max_level: int setget , get_max_level
var charge_p: float setget , get_charge_p

## Null if somewhere else.
var backpack = get_parent() as Component

func _ready() -> void:
	if backpack:
		var _ignore
		var ts: TurnSystem = backpack.turn_system
		_ignore = ts.connect("turn_initiated", self, "_on_turn_initiated")
		_ignore = ts.connect("in_turn", self, "_on_in_turn")
		_ignore = ts.connect("out_of_turn", self, "_out_of_turn")
		var tt: TurnTaker = backpack.entity.get_component(TurnTaker.NAME)
		_ignore = tt.connect("take_turn", self, "_on_take_turn")
		_ignore = backpack.entity.connect("moved", self, "_on_moved")

func _on_turn_initiated() -> void:
	pass

func _on_take_turn() -> void:
	pass

func _on_in_turn() -> void:
	pass

func _out_of_turn() -> void:
	pass

func _on_moved() -> void:
	pass

func get_max_level() -> int:
	return max_charges.size() - 1

func set_level(to: int) -> void:
	if to < 0: to = 0
	if to > self.max_level: to = max_level
	level = to
	emit_signal("level_changed", to, max_level)

func set_charge(to: int) -> void:
	if to < 0: to = 0
	if to > max_charges[level]: to = max_charges[level]
	charge = to
	emit_signal("charge_changed", to, max_charges[level])

func get_charge_p() -> float:
	if max_charges[level] == 0:
		return 1.0
	else:
		return self.charge / max_charges[level]
