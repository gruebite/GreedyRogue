extends Entity
class_name Artifact

const TABLE := {
	"DragonEgg": preload("res://components/backpack/artifacts/dragon_egg/dragon_egg.tscn"),
	"WingedBoots": preload("res://components/backpack/artifacts/winged_boots/winged_boots.tscn"),
}

export(String, MULTILINE) var description := ""
export var max_level := 0
export(PoolIntArray) var max_cooldowns := []

var level: int = 0
var cooldown: int = 0

## Null if somewhere else.
var backpack = get_parent()
