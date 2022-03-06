tool
extends Component
class_name Animated

const NAME := "Animated"

export var background_color := Color.transparent setget set_background_color

export var ascii_frames: SpriteFrames setget set_ascii_frames
export var sprite_frames: SpriteFrames setget set_sprite_frames
export(Brightness.Enum) var brightness: int = Brightness.LIT setget set_brightness
export var frame: int = 0 setget set_frame
export var playing: bool = false setget set_playing

func _ready() -> void:
	# Order matters here (because AnimatedSprite), can't rely on idle frames.
	self.ascii_frames = ascii_frames
	self.sprite_frames = sprite_frames
	self.brightness = brightness
	self.frame = frame
	self.playing = playing

func set_background_color(c: Color) -> void:
	background_color = c
	if not is_inside_tree(): yield(self, "ready")
	$Background.modulate = c

func set_brightness(to: int) -> void:
	brightness = to
	if not is_inside_tree(): yield(self, "ready")
	match brightness:
		Brightness.NONE:
			hide()
		Brightness.LIT:
			show()
			var f: int = $Sprite.frame
			$Sprite.animation = "lit"
			$Sprite.frame = f
		Brightness.DIM:
			show()
			var f: int = $Sprite.frame
			$Sprite.animation = "dim"
			$Sprite.frame = f

func set_ascii_frames(frames: SpriteFrames) -> void:
	ascii_frames = frames
	if not is_inside_tree(): yield(self, "ready")
	if Constants.ASCII:
		$Sprite.frames = frames

func set_sprite_frames(frames: SpriteFrames) -> void:
	sprite_frames = frames
	if not is_inside_tree(): yield(self, "ready")
	if not Constants.ASCII:
		$Sprite.frames = frames

func set_frame(f: int) -> void:
	frame = f
	if not is_inside_tree(): yield(self, "ready")
	$Sprite.frame = f

func set_playing(to: bool) -> void:
	playing = to
	if not is_inside_tree(): yield(self, "ready")
	$Sprite.playing = to

func play() -> void:
	$Sprite.play()

func stop() -> void:
	$Sprite.stop()
