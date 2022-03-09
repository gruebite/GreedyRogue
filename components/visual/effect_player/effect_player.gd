extends Component
class_name EffectPlayer

const NAME := "EffectPlayer"

export(PackedScene) var effect
export var on_ready := false
export var on_turn_initiated := false
export var on_take_turn := false
export var on_in_turn := false
export var on_out_of_turn := false
export var on_died := false

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

func _ready() -> void:
	var _ignore
	if on_turn_initiated:
		_ignore = turn_system.connect("turn_initiated", self, "_on_turn_initiated")
	if turn_taker and on_take_turn:
		_ignore = turn_taker.connect("take_turn", self, "_on_take_turn")
	if on_in_turn:
		_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	if on_out_of_turn:
		_ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")
	if on_died:
		_ignore = entity.connect("died", self, "_on_died")
	if on_ready and effect:
		effect_system.add_effect(effect.instance(), entity.position)

func _on_turn_initiated() -> void:
	if not effect: return
	effect_system.add_effect(effect.instance(), entity.position)

func _on_take_turn() -> void:
	if not effect: return
	effect_system.add_effect(effect.instance(), entity.position)

func _on_in_turn() -> void:
	if not effect: return
	effect_system.add_effect(effect.instance(), entity.position)

func _on_out_of_turn() -> void:
	if not effect: return
	effect_system.add_effect(effect.instance(), entity.position)

func _on_died(_by: Node2D) -> void:
	if not effect: return
	effect_system.add_effect(effect.instance(), entity.position)
