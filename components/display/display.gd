tool
extends Component
class_name Display

const NAME := "Display"

export(Brightness.Enum) var brightness: int = Brightness.LIT setget set_brightness
export var texture: Texture setget set_texture
export var lit_pos: Vector2 setget set_lit_pos
export var dim_pos: Vector2 setget set_dim_pos

func _ready() -> void:
	pass

func set_brightness(to: int) -> void:
	brightness = to
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

func set_texture(tex: Texture) -> void:
	texture = tex
	$Lit.texture = texture
	$Dim.texture = texture

func set_lit_pos(pos: Vector2) -> void:
	lit_pos = pos
	$Lit.region_rect = Rect2(pos, Constants.CELL_VECTOR)

func set_dim_pos(pos: Vector2) -> void:
	dim_pos = pos
	$Dim.region_rect = Rect2(pos, Constants.CELL_VECTOR)
