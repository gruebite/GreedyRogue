extends Artifact

onready var entity_system: EntitySystem

onready var flammable: Flammable

func _ready() -> void:
	if backpack:
		entity_system = backpack.find_system(EntitySystem.NAME)
		flammable = backpack.entity.get_component(Flammable.NAME)

func _on_initiated_turn() -> void:
	if charge_p == 1:
		flammable.immune = false
		return
	flammable.immune = true

	var gpos: Vector2 = backpack.entity.grid_position
	var flamings := entity_system.get_components(gpos.x, gpos.y, Flaming.NAME)
	
	if flamings.size() == 0:
		self.charge -= 1
	else:
		self.charge += 1
