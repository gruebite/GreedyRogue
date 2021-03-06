extends Entity
class_name Artifact

const GROUP_NAME := "artifact"

signal level_changed(to, mx)
signal charge_changed(to, mx)

export(String, MULTILINE) var description := ""
export(PoolIntArray) var max_charges := [0]
export var always_usable := false
export var consumed := false
export var passive := false
export var no_charge := false
export var directional := false

export var starting_level := 0
export var starting_charge := 999
var max_level: int setget , get_max_level
var max_charge: int setget , get_max_charge
var charge_p: float setget , get_charge_p

var charge: int = 0 setget set_charge
var level: int = 0 setget set_level

## Null if somewhere else.
onready var backpack = get_parent() as Component

func _ready() -> void:
	if backpack:
		var _ignore
		var ts: TurnSystem = backpack.turn_system
		_ignore = ts.connect("initiated_turn", self, "_on_initiated_turn")
		_ignore = ts.connect("taken_turns", self, "_on_taken_turns")
		_ignore = ts.connect("out_of_turn", self, "_on_out_of_turn")
		_ignore = backpack.entity.connect("moved", self, "_on_moved")

		self.level = self.starting_level
		self.charge = self.starting_charge

func _on_initiated_turn() -> void:
	pass

func _on_taken_turns() -> void:
	pass

func _on_out_of_turn() -> void:
	pass

func _on_moved(_from: Vector2) -> void:
	pass

# Override.
func use(_dir: int) -> bool:
	return true

func usable() -> bool:
	return always_usable or consumed or (not passive and self.charge_p == 1.0)

func get_max_level() -> int:
	return max_charges.size() - 1

func get_max_charge() -> int:
	return max_charges[level]

func set_level(to: int) -> void:
	if to < 0: to = 0
	if to > self.max_level: to = max_level
	level = to
	self.charge = charge
	emit_signal("level_changed", to, max_level)

func set_charge(to: int) -> void:
	if to < 0: to = 0
	if to > max_charges[level]: to = max_charges[level]
	charge = to
	emit_signal("charge_changed", to, int(max_charges[level]))

func get_charge_p() -> float:
	if max_charges[level] == 0:
		return 1.0
	else:
		return float(charge) / max_charges[level]
