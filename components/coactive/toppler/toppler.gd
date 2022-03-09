extends Component
class_name Toppler

const NAME := "Toppler"

func _ready() -> void:
	var bumper: Bumper = entity.get_component(Bumper.NAME)
	if bumper:
		var _ignore = bumper.connect("bumped", self, "_on_bumped")

func _on_bumped(other: Entity) -> void:
	var toppleable: Toppleable = other.get_component(Toppleable.NAME)
	if toppleable:
		toppleable.topple(entity)
