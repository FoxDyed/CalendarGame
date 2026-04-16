class_name PieceTransform
extends RefCounted

const PieceSet = preload("res://model/pieces/piece_set.gd")

static func rotate_tiles_90(tile_offsets: Array[Vector2i], quarter_turns: int = 1) -> Array[Vector2i]:
	var turns := posmod(quarter_turns, 4)
	var rotated: Array[Vector2i] = tile_offsets.duplicate()

	for _turn in range(turns):
		var next: Array[Vector2i] = []
		for tile in rotated:
			next.append(Vector2i(tile.y, -tile.x))
		rotated = next

	return rotated

static func mirror_tiles(tile_offsets: Array[Vector2i]) -> Array[Vector2i]:
	var mirrored: Array[Vector2i] = []
	for tile in tile_offsets:
		mirrored.append(Vector2i(-tile.x, tile.y))
	return mirrored

static func normalize_tiles(tile_offsets: Array[Vector2i]) -> Array[Vector2i]:
	return PieceSet.normalize_tiles(tile_offsets)

static func get_unique_variants(piece: Dictionary) -> Array:
	if not piece.has("tiles") or not piece.has("transform"):
		return []

	var transform: Dictionary = piece["transform"]
	var allowed_rotations: Array = transform.get("allowed_rotations", [])
	var allow_mirror: bool = transform.get("allow_mirror", false)

	var seeds: Array = [piece["tiles"]]
	if allow_mirror:
		seeds.append(mirror_tiles(piece["tiles"]))

	var seen := {}
	var signatures: Array[String] = []
	var normalized_by_signature := {}

	for seed in seeds:
		for rotation in allowed_rotations:
			var turns := int(rotation) / 90
			var normalized := normalize_tiles(rotate_tiles_90(seed, turns))
			var signature := _signature_for_tiles(normalized)
			if seen.has(signature):
				continue
			seen[signature] = true
			signatures.append(signature)
			normalized_by_signature[signature] = normalized

	signatures.sort()
	var variants: Array = []
	for signature in signatures:
		variants.append(normalized_by_signature[signature])
	return variants

static func get_unique_variant_count(piece: Dictionary) -> int:
	return get_unique_variants(piece).size()

static func _signature_for_tiles(tile_offsets: Array[Vector2i]) -> String:
	var parts: PackedStringArray = []
	for tile in tile_offsets:
		parts.append("%d,%d" % [tile.x, tile.y])
	return "|".join(parts)
