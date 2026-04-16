extends RefCounted

const PieceSet = preload("res://model/pieces/piece_set.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_canonical_piece_set_loads()
	test_piece_ids_are_unique()
	test_every_piece_has_tiles()
	test_no_piece_has_duplicate_local_offsets()
	test_normalization_is_stable_and_deterministic()
	test_transform_metadata_exists_for_every_piece()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_canonical_piece_set_loads() -> void:
	var pieces = PieceSet.list_all_pieces()
	_expect(pieces.size() == 8, "Expected canonical piece set size to be 8")

func test_piece_ids_are_unique() -> void:
	var seen := {}
	for piece in PieceSet.list_all_pieces():
		var piece_id: String = piece["id"]
		_expect(not seen.has(piece_id), "Duplicate piece id found: %s" % piece_id)
		seen[piece_id] = true

func test_every_piece_has_tiles() -> void:
	for piece in PieceSet.list_all_pieces():
		_expect(PieceSet.count_tiles(piece) > 0, "Piece %s should contain at least one tile" % piece["id"])

func test_no_piece_has_duplicate_local_offsets() -> void:
	for piece in PieceSet.list_all_pieces():
		_expect(not PieceSet.has_duplicate_local_offsets(piece), "Piece %s contains duplicate local offsets" % piece["id"])

func test_normalization_is_stable_and_deterministic() -> void:
	var raw: Array[Vector2i] = [Vector2i(4, 7), Vector2i(2, 5), Vector2i(3, 5), Vector2i(2, 6)]
	var once = PieceSet.normalize_tiles(raw)
	var twice = PieceSet.normalize_tiles(once)
	var expected: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(2, 2)]
	_expect(once == expected, "Normalization should produce expected deterministic coordinates")
	_expect(twice == expected, "Normalization should be stable when re-applied")

func test_transform_metadata_exists_for_every_piece() -> void:
	for piece in PieceSet.list_all_pieces():
		_expect(piece.has("transform"), "Piece %s should define transform metadata" % piece["id"])
		var transform: Dictionary = piece["transform"]
		_expect(transform.has("allowed_rotations"), "Piece %s should define allowed_rotations" % piece["id"])
		_expect(transform.has("allow_mirror"), "Piece %s should define allow_mirror" % piece["id"])
		_expect((transform["allowed_rotations"] as Array).size() > 0, "Piece %s should allow at least one rotation" % piece["id"])

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
