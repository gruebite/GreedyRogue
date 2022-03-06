tool
extends Component
class_name Display

const NAME := "Display"

export var background_color := Color.transparent setget set_background_color

export(Brightness.Enum) var brightness: int = Brightness.LIT setget set_brightness
export var ascii_texture: Texture setget set_ascii_texture
export var sprite_texture: Texture setget set_sprite_texture
export var dim_pos: Vector2 setget set_dim_pos
export var lit_pos: Vector2 setget set_lit_pos

func _ready() -> void:
	pass

func set_background_color(c: Color) -> void:
	background_color = c
	if not is_inside_tree(): yield(self, 'ready')
	$Background.modulate = c

func set_brightness(to: int) -> void:
	brightness = to
	if not is_inside_tree(): yield(self, 'ready')
	match brightness:
		Brightness.NONE:
			hide()
		Brightness.LIT:
			show()
			$Lit.show()
			$Dim.hide()
		Brightness.DIM:
			show()
			$Lit.hide()
			$Dim.show()

func set_ascii_texture(tex: Texture) -> void:
	ascii_texture = tex
	if not is_inside_tree(): yield(self, 'ready')
	if Constants.ASCII:
		$Lit.texture = tex
		$Dim.texture = tex

func set_sprite_texture(tex: Texture) -> void:
	sprite_texture = tex
	if not is_inside_tree(): yield(self, 'ready')
	if not Constants.ASCII:
		$Lit.texture = tex
		$Dim.texture = tex

func set_lit_pos(pos: Vector2) -> void:
	lit_pos = pos
	if not is_inside_tree(): yield(self, 'ready')
	$Lit.region_rect = Rect2(pos, Constants.CELL_VECTOR)

func set_dim_pos(pos: Vector2) -> void:
	dim_pos = pos
	if not is_inside_tree(): yield(self, 'ready')
	$Dim.region_rect = Rect2(pos, Constants.CELL_VECTOR)
