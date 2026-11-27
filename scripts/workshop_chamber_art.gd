extends RefCounted
## Places the existing crop artwork in the coordinate space of the painted chamber.

const Art = preload("res://scripts/orbital_art.gd")
# Source pixels in laboratory_background.png.
const GLASS := Rect2(684, 149, 348, 316)
const RIM := Rect2(641, 462, 433, 49)
const SPRITE_SCALE := 0.88
# Stem center, first platform pixels, and bottom of the usable stem in each 512px image.
const STEMS := {
	"seedling": Vector3i(258, 346, 375),
	"growing": Vector3i(256, 345, 379),
	"coffee_mature": Vector3i(257, 345, 379),
	"nutrition_mature": Vector3i(269, 350, 382),
	"kotton_mature": Vector3i(259, 345, 380),
}

var sprite: TextureRect
var foreground: TextureRect
var backdrop: TextureRect
var art: Art
var cutouts: Dictionary = {}
var root_x := 0.0

func _init(parent: Control, background: TextureRect, artwork: Art) -> void:
	backdrop = background
	art = artwork
	sprite = Art.decoration(null)
	parent.add_child(sprite)
	var rim := AtlasTexture.new()
	rim.atlas = backdrop.texture
	rim.region = RIM
	rim.filter_clip = true
	foreground = Art.decoration(rim if rim.atlas != null else null)
	foreground.stretch_mode = TextureRect.STRETCH_SCALE
	parent.add_child(foreground)
	backdrop.resized.connect(_layout)
	_layout()

func render(stage: String) -> void:
	sprite.texture = null
	if stage.is_empty() or backdrop.texture == null:
		return
	var key := stage if art.texture(stage) != null else "growing"
	if not cutouts.has(key):
		_prepare(key)
	if cutouts.has(key):
		sprite.texture = cutouts[key].texture
		root_x = cutouts[key].root_x
		_layout()

func _prepare(key: String) -> void:
	var texture := art.texture(key)
	if texture == null or not STEMS.has(key):
		return
	var mask: Vector3i = STEMS[key]
	var image := texture.get_image()
	if image == null or (image.is_compressed() and image.decompress() != OK):
		return
	image.convert(Image.FORMAT_RGBA8)
	if key == "nutrition_mature":
		# Two disconnected scraps above this sprite are outside the canopy.
		image.fill_rect(Rect2i(48, 150, 51, 35), Color.TRANSPARENT)
		image.fill_rect(Rect2i(351, 150, 80, 28), Color.TRANSPARENT)
	# Remove the painted pedestal below the foliage. Keep only the stem at the base.
	for y in range(mask.y, image.get_height()):
		if y >= mask.z:
			image.fill_rect(Rect2i(0, y, image.get_width(), image.get_height() - y), Color.TRANSPARENT)
			break
		var radius := roundi(lerpf(23.0, 10.0, inverse_lerp(float(mask.y), float(mask.z), y)))
		var right := mask.x + radius
		image.fill_rect(Rect2i(0, y, mask.x - radius, 1), Color.TRANSPARENT)
		image.fill_rect(Rect2i(right, y, image.get_width() - right, 1), Color.TRANSPARENT)
	var bounds := image.get_used_rect()
	if bounds.has_area():
		cutouts[key] = {
			"texture": ImageTexture.create_from_image(image.get_region(bounds)),
			"root_x": float(mask.x - bounds.position.x),
		}

func _layout() -> void:
	if backdrop.texture == null:
		return
	var source_size := backdrop.texture.get_size()
	var cover := maxf(backdrop.size.x / source_size.x, backdrop.size.y / source_size.y)
	var origin := (backdrop.size - source_size * cover) * 0.5
	foreground.position = origin + RIM.position * cover
	foreground.size = RIM.size * cover
	if sprite.texture == null:
		return
	var dimensions := sprite.texture.get_size()
	var fit := minf(SPRITE_SCALE, GLASS.size.y / dimensions.y)
	fit = minf(fit, GLASS.size.x * 0.5 / maxf(root_x, dimensions.x - root_x))
	var scale := fit * cover
	var root := Vector2(GLASS.get_center().x, GLASS.end.y)
	sprite.size = dimensions * scale
	sprite.position = origin + root * cover - Vector2(root_x, dimensions.y) * scale
