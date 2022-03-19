extends Component
class_name DragonlingBehavior

const NAME := "DragonlingBehavior"

enum State {
	SLEEPING,
	BREATHING_WANDERING,
	BREATHING_PURSUING,
	DEFERRING, ## Deferred to the elemental state.
}

signal woke_up()

export var awake_dist := 3
export var dim_range := 4
export var lit_range := 1
export var breath_weapon_chance := 0.1
export var breath_weapon_time := 2
export var breath_weapon_range := 5

# Scale.
export var breath := 1.0 setget set_breath

var state: int = State.SLEEPING
var breath_dir: int = 0
var breath_timer: int = 0

onready var turn_system: TurnSystem = find_system(TurnSystem.GROUP_NAME)
onready var tile_system: TileSystem = find_system(TileSystem.GROUP_NAME)
onready var entity_system: EntitySystem = find_system(EntitySystem.GROUP_NAME)
onready var navigation_system: NavigationSystem = find_system(NavigationSystem.GROUP_NAME)
onready var security_system: SecuritySystem = find_system(SecuritySystem.GROUP_NAME)

onready var display: Display = entity.get_component(Display.NAME)
onready var elemental: Elemental = entity.get_component(Elemental.NAME)
onready var player_anxiety: Anxiety = entity_system.player.get_component(Anxiety.NAME)

# TODO: Used for "stealth".  If bright is disabled, player is stealthy.
onready var player_bright: Bright = entity_system.player.get_component(Bright.NAME)

func _ready() -> void:
	security_system.add_dragon(self)
	var _ignore
	_ignore = elemental.connect("thinking", self, "_on_thinking")
	_ignore = elemental.connect("blanking", self, "_on_blanking")
	_ignore = elemental.connect("wandering", self, "_on_wandering")
	_ignore = elemental.connect("idling", self, "_on_idling")
	_ignore = elemental.connect("distracted", self, "_on_distracted")
	_ignore = elemental.connect("thunk", self, "_on_thunk")

func _exit_tree() -> void:
	security_system.remove_dragon(self)
	turn_system.finish_turn(self)

func _on_thinking() -> void:
	check_transitions()
	match state:
		State.SLEEPING:
			# Nothing.
			pass
		State.BREATHING_WANDERING, State.BREATHING_PURSUING:
			if breath_timer == breath_weapon_time:
				$AnimationPlayer.play("breath_in")
			if breath_timer == 0:
				$AnimationPlayer.play("breath_out")
				breath_fire(breath_dir)
				if state == State.BREATHING_WANDERING:
					elemental.state = Elemental.State.WANDERING
				else:
					elemental.state = Elemental.State.PURSUING
				state = State.DEFERRING
				# Skip this turn since we already acted.
				elemental.skip_this_turn = true
			else:
				breath_timer -= 1
		State.DEFERRING:
			var dv: Vector2 = Direction.delta(navigation_system.cardinal_to(entity.grid_position, entity_system.player.grid_position))
			# Influence bias toward player.
			elemental.last_dir = dv
			pass

func _on_blanking() -> void:
	pass

func _on_wandering() -> void:
	pass

func _on_idling() -> void:
	pass

func _on_distracted() -> void:
	pass

func _on_thunk() -> void:
	pass

func check_transitions() -> void:
	match state:
		State.SLEEPING:
			var v: Vector2 = (entity_system.player.grid_position - entity.grid_position).abs()
			if v.x + v.y <= awake_dist and not player_bright.disabled:
				wake_up()
			else:
				# Do nothing, we asleep.
				elemental.state = Elemental.State.BLANKING
		State.BREATHING_WANDERING, State.BREATHING_PURSUING:
			pass
		State.DEFERRING:
			match elemental.state:
				Elemental.State.WANDERING:
					if randf() <= breath_weapon_chance * 0.1:
						state = State.BREATHING_WANDERING
						elemental.state = Elemental.State.BLANKING
						breath_dir = Direction.CARDINALS[randi() % 4]
						breath_timer = breath_weapon_time
				Elemental.State.PURSUING:
					if randf() <= breath_weapon_chance:
						state = State.BREATHING_PURSUING
						elemental.state = Elemental.State.BLANKING
						breath_dir = navigation_system.cardinal_to(entity.grid_position, entity_system.player.grid_position)
						breath_timer = breath_weapon_time

func wake_up() -> void:
	if state != State.SLEEPING:
		return
	state = State.DEFERRING
	elemental.state = Elemental.State.PURSUING
	entity.get_component(Bright.NAME).disabled = false
	# Set to next frame (big D)
	display.frame = 1
	emit_signal("woke_up")

func breath_fire(dir: int) -> void:
	var cone := PointSets.cone(dir, breath_weapon_range, 0.5)
	var dirv := Direction.delta(dir)
	for dv in cone.array:
		var gpos: Vector2 = entity.grid_position + dv + dirv
		if tile_system.blocks_movement(gpos.x, gpos.y):
			continue
		var _ignore = entity_system.spawn_entity(preload("res://entities/fire/fire.tscn"), gpos)

func set_breath(value: float) -> void:
	breath = value
	if display:
		display.scale = Vector2(breath, breath)
