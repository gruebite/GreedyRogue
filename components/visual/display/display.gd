tool
extends Component
class_name Display

const NAME := "Display"

export var background_color := Color.transparent setget set_background_color

export(Brightness.Enum) var brightness: int = Brightness.LIT setget set_brightness
export var frames: SpriteFrames setget set_frames, get_frames
export var playing: bool setget set_playing, get_playing
export var frame: int setget set_frame, get_frame

export var jitter := true

func _ready() -> void:
	self.frames = frames
	self.playing = playing
	if jitter:
		if self.frames.has_animation("dim"):
			self.frame = randi() % self.frames.get_frame_count("dim")
		elif self.frames.has_animation("lit"):
			self.frame = randi() % self.frames.get_frame_count("lit")

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
				var f = $Foreground.frame
				$Foreground.animation = "lit"
				$Foreground.frame = f
			else:
				$Foreground.hide()
		Brightness.DIM:
			show()
			if $Foreground.frames.has_animation("dim"):
				$Foreground.show()
				var f = $Foreground.frame
				$Foreground.animation = "dim"
				$Foreground.frame = f
			else:
				$Foreground.hide()

func set_frames(fs: SpriteFrames) -> void:
	frames = fs
	$Foreground.frames = fs

func get_frames() -> SpriteFrames:
	return $Foreground.frames

func set_frame(f: int) -> void:
	frame = f
	$Foreground.frame = f

func get_frame() -> int:
	return $Foreground.frame

func set_playing(p: bool) -> void:
	playing = p
	$Foreground.playing = p

func get_playing() -> bool:
	return $Foreground.playing
