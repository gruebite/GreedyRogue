extends Component
class_name Bomb

const NAME := "Bomb"

export(PackedScene) var spawns
export var active := false
export var time := 5
export var radius := 3
# TODO: Separate frame controls from behavior.
export var frame := 1

onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)

onready var display: Display = entity.get_component(Display.NAME)

func _ready() -> void:
	var _ignore
	_ignore = find_system(TurnSystem.GROUP_NAME).connect("initiated_turn", self, "_on_initiated_turn")
	_ignore = entity.connect("died", self, "_on_died")

func _on_initiated_turn() -> void:
	if not active or time < 0:
		return
	time -= 1
	if time >= 0:
		# Not yet.
		display.frame = frame
		frame += 1
	else:
		explode()
		entity.kill("exploded")

func _on_died(_source: String) -> void:
	explode()

func explode() -> void:
	if spawns and active:
		var circle := PointSets.circle(radius)
		for ps in circle.array:
			entity_system.spawn_entity(
				spawns,
				entity.grid_position + ps)
