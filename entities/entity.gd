extends Node2D
class_name Entity

enum Layer {
	BELOW = -1,
	GROUND,
	WAIST,
	HEAD,
	OVERHEAD,
	AIR,
}

signal moved(from)
signal died(source)

export var id := ""

export var invincible := false
export(Layer) var layer := Layer.GROUND setget set_layer

var dead := false
var grid_position: Vector2 setget set_grid_position, get_grid_position

func _ready() -> void:
	self.layer = layer

func set_grid_position(value: Vector2) -> void:
	position = value * Constants.CELL_SIZE

func get_grid_position() -> Vector2:
	return (position / Constants.CELL_SIZE).floor()

func get_component(path: String) -> Node2D:
	return find_node(path) as Node2D

func move(value: Vector2) -> void:
	var from := self.grid_position
	self.grid_position = value
	emit_signal("moved", from)

func kill(source: String="unknown") -> void:
	if dead:
		return
	dead = true
	emit_signal("died", source)
	if not invincible:
		queue_free()

func set_layer(l: int) -> void:
	layer = l
	z_index = layer
