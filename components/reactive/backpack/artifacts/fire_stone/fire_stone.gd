extends Artifact

onready var entity_system: EntitySystem

onready var flammable: Flammable

func _ready() -> void:
	if backpack:
		entity_system = backpack.find_system(EntitySystem.GROUP_NAME)
		flammable = backpack.entity.get_component(Flammable.NAME)

func _on_initiated_turn() -> void:
	flammable.immune = self.charge_p != 1
	
	var gpos: Vector2 = backpack.entity.grid_position
	var flamings := entity_system.get_components(gpos.x, gpos.y, Flaming.NAME)

	if flamings.size() == 0:
		self.charge -= 1
	else:
		self.charge += 1
	
	if charge > 0:
		for art in backpack.get_artifacts():
			if art == self:
				continue
			if art.passive or art.no_charge:
				continue
			art.charge += int(ceil(art.max_charge * 0.05))
