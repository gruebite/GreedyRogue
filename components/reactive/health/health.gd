extends Component
class_name Health

const NAME := "Health"

signal health_changed(to, mx)

export var flashing_node_path := NodePath("../Display")
export var flame_immune := false
export var harm_immune := false
export var attack_immune := false

export var max_health := 12 setget set_max_health
var health := max_health

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)

onready var defender := entity.get_component(Defender.NAME)

onready var flashing_node := get_node(flashing_node_path)

var transparency: float = 0 setget set_transparency

func _ready() -> void:
	var flammable := entity.get_component(Flammable.NAME)
	if flammable:
		var _ignore = flammable.connect("burned", self, "_on_burned")
	var harmable := entity.get_component(Harmable.NAME)
	if harmable:
		var _ignore = harmable.connect("harmed", self, "_on_harmed")
	if defender:
		var _ignore = defender.connect("attacked", self, "_on_attacked")
	emit_signal("health_changed", health, max_health)

func _exit_tree() -> void:
	turn_system.finish_turn(self)

func _on_burned(by: Entity) -> void:
	if flame_immune:
		return
	deal_damage(by.get_component(Flaming.NAME).heat, "burns")

func _on_harmed(by: Entity) -> void:
	if harm_immune:
		return
	deal_damage(by.get_component(Harmer.NAME).damage, "trauma")

func _on_attacked(by: Entity) -> void:
	if attack_immune:
		return
	var attacker: Attacker = by.get_component(Attacker.NAME)
	var dmg: int = attacker.damage - defender.armor
	if dmg <= 0:
		return
	deal_damage(dmg, "trauma")

func set_max_health(to: int) -> void:
	if to < 0: to = 0
	max_health = to
	if max_health < health:
		health = max_health
	if health == 0:
		entity.kill("max health too low")
	emit_signal("health_changed", health, max_health)

func deal_damage(amount: int, source: String="unknown") -> void:
	var to := health - amount
	if to < 0: to = 0
	if to > max_health: to = max_health
	if to < health:
		effect_system.add_effect(preload("res://effects/blood/blood.tscn"), entity.position)
		flash()
	health = to
	if health == 0:
		entity.kill(source)
	emit_signal("health_changed", health, max_health)

func set_transparency(value: float) -> void:
	transparency = value
	if flashing_node:
		flashing_node.modulate.a = 1 - transparency

func flash() -> void:
	$AnimationPlayer.play("flash")
	# Only do this if we're in turn.
	#if turn_system.state == TurnSystem.IN_TURN:
	turn_system.taking_turn(self)
	yield($AnimationPlayer, "animation_finished")
	turn_system.finish_turn(self)
