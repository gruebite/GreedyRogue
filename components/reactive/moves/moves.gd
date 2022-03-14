extends Component
class_name Moves

const NAME := "Moves"

signal move_succeeded(from)
signal move_failed(to)

export var inverse := false

export var on_bump := false
export var on_attack := false
export var on_knockback := false

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)

func _ready() -> void:
	var _ignore
	if on_bump:
		_ignore = entity.get_component(Bumpable.NAME).connect("bumped", self, "_on_bumped")
	if on_attack:
		_ignore = entity.get_component(Attackable.NAME).connect("attacked", self, "_on_attacked")
	if on_knockback:
		_ignore = entity.get_component(Knockbackable.NAME).connect("knocked_back", self, "_on_kocked_back")

func _on_bumped(by: Bumper) -> void:
	make_move(by.entity)

func _on_attacked(by: Attacker) -> void:
	make_move(by.entity)

func _on_kocked_back(by: Knockbacker) -> void:
	make_move(by.entity)

func make_move(by: Entity) -> void:
	var gpos := entity.grid_position
	var dv := gpos - by.grid_position
	var desired := gpos + dv * (-1 if inverse else 1)
	if navigation_system.can_move_to(entity, desired):
		navigation_system.move_to(entity, desired)
		emit_signal("move_succeeded", gpos)
	else:
		emit_signal("move_failed", desired)
