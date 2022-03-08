extends Node2D
class_name EntitySystem

const GROUP_NAME := "entity_system"

export(PackedScene) var player_scene := load("res://entities/player/player.tscn")
export var entities_node_path := NodePath("../Entities")

# Vector2 -> {Entity}
var entity_grid := {}
# Entity -> Vector2
var entity_positions := {}

onready var entities_node: Node2D = get_node(entities_node_path)
var player: Entity

func _ready() -> void:
	assert(get_tree().get_nodes_in_group(GROUP_NAME).size() == 0)
	add_to_group(GROUP_NAME)

	for x in Constants.MAP_COLUMNS:
		for y in Constants.MAP_ROWS:
			entity_grid[Vector2(x, y)] = {}

func reset() -> void:
	for ent in entities_node.get_children():
		ent.queue_free()
	spawn_entity(player_scene, Vector2.ZERO)
	player = entities_node.get_child(0)

func spawn_entity(escene: PackedScene, gpos: Vector2) -> void:
	var ent: Entity = escene.instance()
	ent.grid_position = gpos
	add_entity(ent)

func add_entity(entity: Entity) -> void:
	#print("[entity_system.add] " + entity.name)
	entities_node.add_child(entity)

func update_entity(entity: Entity) -> void:
	#print("[entity_system.update] " + entity.name)
	if entity_positions.has(entity):
		var old_position: Vector2 = entity_positions[entity]
		entity_grid[old_position].erase(entity)
	entity_positions[entity] = entity.grid_position
	entity_grid[entity.grid_position][entity] = true

func remove_entity(entity: Entity) -> void:
	#print("[entity_system.remove] " + entity.name)
	if entity_positions.has(entity):
		var old_position: Vector2 = entity_positions[entity]
		entity_grid[old_position].erase(entity)
		var _ignore = entity_positions.erase(entity)

func get_entities(x: int, y: int) -> Dictionary:
	return entity_grid[Vector2(x, y)]

func get_components(x: int, y: int, comp_name: String) -> Array:
	var comps := []
	for ent in entity_grid[Vector2(x, y)]:
		var comp = ent.get_component(comp_name)
		if comp != null:
			comps.append(comp)
	return comps

func set_brightness(x: int, y: int, brightness: int) -> void:
	var ents := get_entities(x, y)
	for ent in ents:
		var disp = ent.get_component(Display.NAME)
		if disp != null:
			disp.brightness = brightness
		var anim = ent.get_component(Animated.NAME)
		if anim != null:
			anim.brightness = brightness
