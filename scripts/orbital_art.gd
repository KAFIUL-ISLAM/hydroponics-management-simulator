extends RefCounted

const ROOT := "res://assets/orbital_assets/"
const PATHS := {
	"laboratory": "laboratory_background.png", "tank": "liquid_tank.png",
	"terminal": "terminal.png", "station": "dna_station.png", "water": "water_icon.png",
	"machine": "chamber.png", "analyser": "terminal.png",
	"energy": "runtime/energy_icon.png", "dna": "dna_icon.png", "module": "module_icon.png",
	"seed": "seed_packet.png", "nutrition": "nutrition_icon.png", "coffee": "coffee_icon.png",
	"kotton": "kotton_icon.png", "seedling": "runtime/seedling_shared.png",
	"growing": "runtime/growing_shared.png", "nutrition_mature": "runtime/nutrition_mature.png",
	"kotton_mature": "runtime/kotton_mature.png", "coffee_mature": "runtime/coffee_mature.png",
}

var textures: Dictionary[String, Texture2D] = {}

func _init() -> void:
	for key: String in PATHS:
		var path: String = ROOT + PATHS[key]
		if ResourceLoader.exists(path, "Texture2D"):
			textures[key] = load(path) as Texture2D
	# Small presentation glyph for the existing nutrient item.
	var tablet := Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	tablet.fill_rect(Rect2i(3, 5, 10, 6), Color("#264961"))
	tablet.fill_rect(Rect2i(4, 4, 8, 8), Color("#264961"))
	tablet.fill_rect(Rect2i(4, 5, 8, 5), Color("#8de3e0"))
	tablet.fill_rect(Rect2i(5, 5, 3, 1), Color("#e1ffff"))
	tablet.fill_rect(Rect2i(8, 6, 1, 4), Color("#4b9db4"))
	textures["tablet"] = ImageTexture.create_from_image(tablet)
	for key: String in ["nutrition", "kotton"]:
		if not textures.has("seed") or not textures.has(key):
			continue
		# Reuse the existing packet art with the crop glyph printed on the front.
		var packet := textures["seed"].get_image()
		var crop := textures[key].get_image()
		packet.convert(Image.FORMAT_RGBA8)
		crop.convert(Image.FORMAT_RGBA8)
		crop.resize(roundi(packet.get_width() * 0.38), roundi(packet.get_height() * 0.38), Image.INTERPOLATE_NEAREST)
		packet.blend_rect(crop, crop.get_used_rect(), Vector2i(roundi(packet.get_width() * 0.32), roundi(packet.get_height() * 0.30)))
		textures[key + "_seed"] = ImageTexture.create_from_image(packet)

func texture(key: String, fallback: String = "") -> Texture2D:
	return textures.get(key, textures.get(fallback))

static func species_key(species: int) -> String:
	match species:
		ReferenceCrop.Species.NUTRITION: return "nutrition"
		ReferenceCrop.Species.KOTTON: return "kotton"
		ReferenceCrop.Species.COFFEE: return "coffee"
	return ""

static func crop_key(crop_id: String) -> String:
	match crop_id:
		"coffee_beans": return "coffee"
		"kotton": return "kotton"
		"nutrition_fruit": return "nutrition"
		"lettuce", "lettuce_prototype": return "seedling"
	return "seed"

static func decoration(image: Texture2D) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.texture = image
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sprite
