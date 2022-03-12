extends Component
class_name Backpack

const NAME := "Backpack"

const MAX_ARTIFACTS := 5

signal picked_up_gold()
signal picked_up_treasure()
signal gained_artifact(artifact)
signal artifact_level_changed(artifact, to, mx)
signal artifact_charge_changed(artifact, to, mx)
signal artifact_consuming(artifact)

onready var generator_system: GeneratorSystem = find_system(GeneratorSystem.GROUP_NAME)
onready var effect_system: EffectSystem = find_system(EffectSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)

onready var health: Health = entity.get_component(Health.NAME)
onready var anxiety: Anxiety = entity.get_component(Anxiety.NAME)

func _ready() -> void:
	var _ignore
	var pickerupper: Pickerupper = entity.get_component(Pickerupper.NAME)
	if pickerupper:
		_ignore = pickerupper.connect("picked_up", self, "_on_picked_up")

func _on_picked_up(pickup: Pickupable) -> void:
	if pickup.entity.get_component(Gold.NAME):
		try_pickup_gold(pickup)
	if pickup.entity.get_component(Treasure.NAME):
		try_pickup_treasure(pickup)

func try_pickup_gold(pickup: Node2D=null) -> void:
	anxiety.anxiety -= 15
	effect_system.add_effect(preload("res://effects/collect_gold/collect_gold.tscn"), entity.grid_position)
	emit_signal("picked_up_gold")
	# TODO: Should we do this here?
	if pickup:
		pickup.entity.kill("being picked up")

func try_pickup_treasure(pickup: Node2D=null) -> void:
	if is_full():
		# Pickup destroys the item.  We need a new one.  Deferred so we don't just iterate to
		# this one while picking up.
		entity_system.call_deferred("spawn_entity",
			preload("res://entities/treasure_chest/treasure_chest.tscn"),
			entity.grid_position)
	else:
		emit_signal("picked_up_treasure")
	# TODO: Should we do this here?
	if pickup:
		pickup.entity.kill("being picked up")

func random_artifacts() -> Array:
	assert(not is_full())
	var pool := []
	for name in Artifacts.NAMES:
		if has_artifact(name):
			if artifact_at_max_level(name):
				continue
			else:
				pool.append(name)
		elif get_artifact_count() < MAX_ARTIFACTS:
			pool.append(name)
	pool.shuffle()
	var got := []
	for i in 3:
		if pool.size() == 0:
			break
		got.append(pool.pop_back())
	return got

func add_artifact(n: String) -> void:

	var existing := find_artifact(n)
	if existing:
		existing.level += 1
		existing.charge += 999
		return

	var artifact = Artifacts.TABLE[n].instance()
	add_child(artifact)
	artifact.connect("level_changed", self, "_on_level_changed", [artifact])
	artifact.connect("charge_changed", self, "_on_charge_changed", [artifact])
	artifact.connect("tree_exiting", self, "_on_artifact_consuming", [artifact])
	emit_signal("gained_artifact", artifact)
	artifact.charge = artifact.max_charge
	artifact.get_component(Display.NAME).hide()

func find_artifact(n: String) -> Node2D:
	for i in get_artifact_count():
		var existing := get_artifact(i)
		if existing.id == n:
			return existing
	return null

func get_artifact(index: int) -> Node2D:
	if index < 0 or index >= get_child_count():
		return null
	return get_child(index) as Node2D

func get_artifacts() -> Array:
	return get_children()

func get_artifact_count() -> int:
	return get_child_count()

func is_full() -> bool:
	return get_artifact_count() == MAX_ARTIFACTS and not has_artifact_upgrades()

func has_artifact(n: String) -> bool:
	return not not find_artifact(n)

func artifact_at_max_level(n: String) -> bool:
	var art := find_artifact(n)
	assert(art)
	return art.level == art.max_level

func has_artifact_upgrades() -> bool:
	for art in get_children():
		if art.level != art.max_level:
			return true
	return false

func artifact_level(n: String) -> int:
	var art := find_artifact(n)
	assert(art)
	return art.level

func _on_level_changed(to, mx, artifact) -> void:
	emit_signal("artifact_level_changed", artifact, to, mx)

func _on_charge_changed(to, mx, artifact) -> void:
	emit_signal("artifact_charge_changed", artifact, to, mx)

func _on_artifact_consuming(artifact) -> void:
	emit_signal("artifact_consuming", artifact)
