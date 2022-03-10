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
	player = player_scene.instance()
	add_entity(player, Vector2.ZERO)

func spawn_entity(scene: PackedScene, gpos: Vector2, unique: bool=true) -> void:
	var entity: Entity = scene.instance()
	if unique:
		var entities := get_entities(gpos.x, gpos.y)
		# This should work for everything that is instantiated in code (not in-scene).
		for ent in entities:
			if ent.filename == scene.resource_path:
				return
	add_entity(entity, gpos)

func add_entity(entity: Node2D, gpos=null) -> void:
	if gpos:
		entity.grid_position = gpos
	entities_node.add_child(entity)

func update_entity(entity: Entity) -> void:
	#print("[entity_system.update] " + entity.name)
	if entity_positions.has(entity):
		var old_position: Vector2 = entity_positions[entity]
		entity_grid[old_position].erase(entity)
	entity_positions[entity] = entity.grid_position
	entity_grid[entity.grid_position][entity] = true

func unregister_entity(entity: Entity) -> void:
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

func get_first_top_entity(x: int, y: int) -> Entity:
	var ents := get_entities(x, y)
	var top: Entity = null
	for ent in ents:
		if not top or ent.layer > top.layer:
			top = ent
	return top
