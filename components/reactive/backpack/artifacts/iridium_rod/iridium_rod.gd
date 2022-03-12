extends Artifact

var tile_system: TileSystem
var effect_system: EffectSystem
var entity_system: EntitySystem
var navigation_system: NavigationSystem

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)

func _on_out_of_turn() -> void:
	self.charge += 1

func use(dir: int) -> bool:
	var gpos = backpack.entity.grid_position
	var dv := Direction.delta(dir)
	var nextpos: Vector2 = gpos + dv
	if not navigation_system.is_lava(nextpos.x, nextpos.y):
		return false
	if backpack.is_full():
		return false
	self.charge = 0
	backpack.add_artifact("Lava Eel")
	return true
