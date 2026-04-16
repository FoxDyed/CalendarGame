extends RefCounted

const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceTransform = preload("res://model/pieces/piece_transform.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_four_rotations_return_to_original_shape()
	test_double_mirror_returns_to_original_shape()
	test_duplicate_variants_are_removed()
	test_restricted_rotations_only_generate_allowed_variants()
	test_disabling_mirror_excludes_mirrored_only_variants()
	test_variant_generation_is_deterministic()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_four_rotations_return_to_original_shape() -> void:
	var piece := _piece_by_id("L5")
	var normalized = PieceTransform.normalize_tiles(piece["tiles"])
	var rotated = piece["tiles"]
	for _idx in range(4):
		rotated = PieceTransform.rotate_tiles_90(rotated, 1)
	rotated = PieceTransform.normalize_tiles(rotated)
	_expect(rotated == normalized, "Four 90-degree rotations should return to original normalized tiles")

func test_double_mirror_returns_to_original_shape() -> void:
	var piece := _piece_by_id("Z6")
	var normalized = PieceTransform.normalize_tiles(piece["tiles"])
	var mirrored_twice = PieceTransform.mirror_tiles(PieceTransform.mirror_tiles(piece["tiles"]))
	mirrored_twice = PieceTransform.normalize_tiles(mirrored_twice)
	_expect(mirrored_twice == normalized, "Mirroring twice should return to original normalized tiles")

func test_duplicate_variants_are_removed() -> void:
	var piece := _piece_by_id("P8")
	var variants = PieceTransform.get_unique_variants(piece)
	_expect(variants.size() == 2, "P8 should deduplicate to two unique variants")
	_expect(PieceTransform.get_unique_variant_count(piece) == 2, "Variant count helper should match deduplicated variant total")

func test_restricted_rotations_only_generate_allowed_variants() -> void:
	var piece := (_piece_by_id("L5") as Dictionary).duplicate(true)
	piece["transform"]["allowed_rotations"] = [0, 180]
	piece["transform"]["allow_mirror"] = false

	var variants = PieceTransform.get_unique_variants(piece)
	_expect(variants.size() == 2, "Restricted rotation piece should produce exactly allowed unique variants")

	var expected_signatures := {}
	for degrees in [0, 180]:
		var turns := int(degrees) / 90
		var normalized = PieceTransform.normalize_tiles(PieceTransform.rotate_tiles_90(piece["tiles"], turns))
		expected_signatures[_signature(normalized)] = true

	for variant in variants:
		_expect(expected_signatures.has(_signature(variant)), "Generated variant must be from an allowed rotation")

func test_disabling_mirror_excludes_mirrored_only_variants() -> void:
	var mirrored_piece := (_piece_by_id("L5") as Dictionary).duplicate(true)
	mirrored_piece["transform"]["allow_mirror"] = true

	var unmirrored_piece := (mirrored_piece as Dictionary).duplicate(true)
	unmirrored_piece["transform"]["allow_mirror"] = false

	var variants_with_mirror = PieceTransform.get_unique_variants(mirrored_piece)
	var variants_without_mirror = PieceTransform.get_unique_variants(unmirrored_piece)
	_expect(variants_without_mirror.size() < variants_with_mirror.size(), "Disabling mirror should remove mirrored-only variants")

	var without_mirror_signatures := {}
	for variant in variants_without_mirror:
		without_mirror_signatures[_signature(variant)] = true

	var has_mirrored_only := false
	for variant in variants_with_mirror:
		if not without_mirror_signatures.has(_signature(variant)):
			has_mirrored_only = true
			break
	_expect(has_mirrored_only, "Mirror-enabled generation should include at least one mirrored-only variant")

func test_variant_generation_is_deterministic() -> void:
	var piece := _piece_by_id("Z6")
	var first = PieceTransform.get_unique_variants(piece)
	var second = PieceTransform.get_unique_variants(piece)
	_expect(first == second, "Variant generation should return a deterministic ordering")

func _piece_by_id(piece_id: String) -> Dictionary:
	for piece in PieceSet.list_all_pieces():
		if piece["id"] == piece_id:
			return piece
	return {}

func _signature(tile_offsets: Array[Vector2i]) -> String:
	var parts: PackedStringArray = []
	for tile in tile_offsets:
		parts.append("%d,%d" % [tile.x, tile.y])
	return "|".join(parts)

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
