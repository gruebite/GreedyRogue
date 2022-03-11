extends Component
class_name Toppler

const NAME := "Toppler"

signal toppled(other)

func _ready() -> void:
	var bumper: Bumper = entity.get_component(Bumper.NAME)
	if bumper:
		var _ignore = bumper.connect("bumped", self, "_on_bumped")

func _on_bumped(other: Bumpable) -> void:
	var toppleable: Toppleable = other.entity.get_component(Toppleable.NAME)
	if toppleable:
		emit_signal("toppled", toppleable)
		toppleable.topple(self)
