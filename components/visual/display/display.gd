tool
extends Component
class_name Display

const NAME := "Display"

export var background_color := Color.transparent setget set_background_color

export(Brightness.Enum) var brightness: int = Brightness.LIT setget set_brightness
export var frames: SpriteFrames setget set_frames

export var frame := 0 setget set_frame
export var playing := false setget set_playing

export var jitter := true

func _ready() -> void:
	if jitter:
		if frames.has_animation("dim"):
			frame = randi() % frames.get_frame_count("dim")
		elif  frames.has_animation("lit"):
			frame = randi() % frames.get_frame_count("lit")

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
			if $Foreground.frames.has_animation("lit"):
				$Foreground.show()
				$Foreground.animation = "lit"
				$Foreground.frame = playing
				$Foreground.frame = frame
			else:
				$Foreground.hide()
		Brightness.DIM:
			show()
			if $Foreground.frames.has_animation("dim"):
				$Foreground.show()
				$Foreground.animation = "dim"
				$Foreground.frame = playing
				$Foreground.frame = frame
			else:
				$Foreground.hide()

func set_frames(fs: SpriteFrames) -> void:
	frames = fs
	if not is_inside_tree(): yield(self, 'ready')
	$Foreground.frames = fs

func set_frame(f: int) -> void:
	frame = f
	if not is_inside_tree(): yield(self, 'ready')
	$Foreground.frame = f

func set_playing(p: bool) -> void:
	playing = p
	if not is_inside_tree(): yield(self, 'ready')
	$Foreground.playing = p
