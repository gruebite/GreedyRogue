extends Artifact

var tile_system: TileSystem
var effect_system: EffectSystem
var entity_system: EntitySystem
var navigation_system: NavigationSystem

onready var scooper: Scooper = get_component(Scooper.NAME)

var containing_id := ""

func _ready() -> void:
	if backpack:
		tile_system = backpack.find_system(TileSystem.GROUP_NAME)
		effect_system = backpack.find_system(EffectSystem.GROUP_NAME)
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		navigation_system = backpack.find_system(NavigationSystem.GROUP_NAME)
	
	self.charge = 0

func use(dir: int) -> bool:
	var gpos = backpack.entity.grid_position
	var dv := Direction.delta(dir)
	var nextpos: Vector2 = gpos + dv
	# We're full, use it
	if self.charge == self.max_charge:
		assert(containing_id != "")
		var scene = load(containing_id)
		for i in self.charge:
			var testpos: Vector2 = gpos + dv * (i + 1)
			if tile_system.blocks_movement(testpos.x, testpos.y):
				break
			entity_system.spawn_entity(scene, testpos)
		self.charge = 0
		self.containing_id = ""
	# We're not full, add charges.
	else:
		var scoopables := entity_system.get_components(nextpos.x, nextpos.y, Scoopable.NAME)
		if scoopables.size() == 0:
			return false
		for scoopable in scoopables:
			if containing_id == "":
				containing_id = scoopable.entity.filename
				scooper.scoop(scoopable)
				self.charge += 1
			elif containing_id == scoopable.entity.filename:
				scooper.scoop(scoopable)
				self.charge += 1
			else:
				pass
	return true
