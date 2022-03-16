extends Component
class_name EffectPlayer

const NAME := "EffectPlayer"

export(PackedScene) var effect
export(Palette.Enum) var effect_color
export var effect_amount_scale := 1.0
export var on_ready := false
export var on_turn_initiated := false
export var on_take_turn := false
export var on_in_turn := false
export var on_out_of_turn := false
export var on_died := false
export var on_time := -1.0
export var on_time_randomness := 1.0

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var turn_taker: TurnTaker = entity.get_component("TurnTaker")

onready var time_accum: float = randf() * on_time * on_time_randomness

func _ready() -> void:
	var _ignore
	if on_turn_initiated:
		_ignore = turn_system.connect("initiated_turn", self, "_on_initiated_turn")
	if turn_taker and on_take_turn:
		_ignore = turn_taker.connect("take_turn", self, "_on_take_turn")
	if on_in_turn:
		_ignore = turn_system.connect("in_turn", self, "_on_in_turn")
	if on_out_of_turn:
		_ignore = turn_system.connect("out_of_turn", self, "_on_out_of_turn")
	if on_died:
		_ignore = entity.connect("died", self, "_on_died")
	if on_ready and effect:
		play()

func _process(delta: float) -> void:
	if on_time < 0:
		return
	time_accum += delta
	if time_accum >= on_time:
		time_accum = randf() * on_time * on_time_randomness
		play()

func _on_initiated_turn() -> void:
	if not effect: return
	play()

func _on_take_turn() -> void:
	if not effect: return
	play()

func _on_in_turn() -> void:
	if not effect: return
	play()

func _on_out_of_turn() -> void:
	if not effect: return
	play()

func _on_died(_by: Node2D) -> void:
	if not effect: return
	play()

func play() -> void:
	effect_system.add_effect(effect, entity.grid_position, effect_color, effect_amount_scale)
