extends Component
class_name Backpack

const NAME := "Backpack"

const MAX_ARTIFACTS := 5

signal picked_up_gold()
signal picked_up_treasure()
signal gold_changed(to)
signal gained_artifact(artifact)
signal artifact_level_changed(artifact, to, mx)
signal artifact_charge_changed(artifact, to, mx)

export var gold := 0 setget set_gold

onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var health: Health = entity.get_component(Health.NAME)
onready var anxiety: Anxiety = entity.get_component(Anxiety.NAME)

func _ready() -> void:
	var _ignore
	var pickerupper: Pickerupper = entity.get_component(Pickerupper.NAME)
	if pickerupper:
		_ignore = pickerupper.connect("picked_up", self, "_on_picked_up")

func _on_picked_up(ent: Entity) -> void:
	if ent.get_component(Gold.NAME):
		self.gold += (randi() % 5) + 5
		anxiety.anxiety -= 10
		effect_system.add_effect(preload("res://effects/collect_gold/collect_gold.tscn").instance(), entity.position)
		emit_signal("picked_up_gold")
	if ent.get_component(Treasure.NAME):
		emit_signal("picked_up_treasure")

func set_gold(to: int) -> void:
	gold = to
	emit_signal("gold_changed", to)

func add_artifact(n: String) -> void:
	if n in Artifacts.CONSUMED:
		match n:
			"Health Potion":
				health.health += 100
			"Heart Piece":
				health.max_health *= 1.5
			"Golden Chalice":
				self.gold += 100
				anxiety.anxiety -= 100
			"Liquid Courage":
				anxiety.max_anxiety *= 1.2
		return

	var existing := find_node(n, false, false)
	if existing:
		existing.level += 1
		existing.charge += 999
		return

	assert(get_child_count() < MAX_ARTIFACTS)
	var artifact = Artifacts.TABLE[n].instance()
	add_child(artifact)
	artifact.connect("level_changed", self, "_on_level_changed", [artifact])
	artifact.connect("charge_changed", self, "_on_charge_changed", [artifact])
	emit_signal("gained_artifact", artifact)
	artifact.charge = artifact.max_charge
	artifact.get_component(Display.NAME).hide()

func get_artifact(index: int) -> Node2D:
	if index < 0 or index >= get_child_count():
		return null
	return get_child(index) as Node2D

func get_artifacts() -> Array:
	return get_children()

func get_artifact_count() -> int:
	return get_child_count()

func is_full() -> bool:
	return get_artifact_count() == MAX_ARTIFACTS

func artifact_at_max_level(n: String) -> bool:
	var art := find_node(n, false, false)
	if not art:
		return false
	else:
		return art.level == art.max_level

func artifact_level(n: String) -> int:
	var art := find_node(n, false, false)
	if not art:
		return -1
	else:
		return art.level

func _on_level_changed(to, mx, artifact) -> void:
	emit_signal("artifact_level_changed", artifact, to, mx)

func _on_charge_changed(to, mx, artifact) -> void:
	emit_signal("artifact_charge_changed", artifact, to, mx)