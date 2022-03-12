extends Artifact

var anxiety: Anxiety

func _ready() -> void:
    if backpack:
        anxiety = backpack.entity.get_component(Anxiety.NAME)


func use(_dir: int) -> bool:
    anxiety.max_anxiety += 50
    queue_free()
    return true