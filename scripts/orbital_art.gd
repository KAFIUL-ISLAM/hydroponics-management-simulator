extends RefCounted

const ROOT := "res://assets/orbital_assets/"
const PATHS := {
	"laboratory": "laboratory_background.png", "tank": "liquid_tank.png",
	"terminal": "terminal.png", "station": "dna_station.png", "water": "water_icon.png",
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

func texture(key: String, fallback: String = "") -> Texture2D:
	return textures.get(key, textures.get(fallback))

static func species_key(species: int) -> String:
	match species:
		ReferenceCrop.Species.NUTRITION: return "nutrition"
		ReferenceCrop.Species.KOTTON: return "kotton"
		ReferenceCrop.Species.COFFEE: return "coffee"
	return ""

static func decoration(image: Texture2D) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.texture = image
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sprite
