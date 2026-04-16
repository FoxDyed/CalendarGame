extends RefCounted

const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceTrayScene = preload("res://scenes/gameplay/piece_tray_scene.tscn")

var _failures: Array[String] = []

func run_all() -> bool:
	test_tray_populates_with_all_canonical_pieces_once()
	test_piece_ids_are_unique_and_resolvable()
	test_reset_pieces_to_spawn_positions_restores_layout()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_tray_populates_with_all_canonical_pieces_once() -> void:
	var tray := PieceTrayScene.instantiate() as PieceTrayController
	_expect(tray != null, "Expected PieceTray scene to instantiate")
	if tray == null:
		return

	tray._ready()

	var expected_ids := _canonical_piece_ids()
	_expect(tray.get_piece_count() == expected_ids.size(), "Tray should spawn one piece per canonical piece definition")
	_expect(tray.get_piece_ids().size() == expected_ids.size(), "Tray ID list should include every spawned piece")
	tray.queue_free()

func test_piece_ids_are_unique_and_resolvable() -> void:
	var tray := PieceTrayScene.instantiate() as PieceTrayController
	if tray == null:
		_expect(false, "Expected PieceTray scene to instantiate for ID checks")
		return

	tray._ready()

	var ids := tray.get_piece_ids()
	var seen := {}
	for piece_id in ids:
		_expect(not seen.has(piece_id), "Each canonical piece ID should appear only once in tray")
		seen[piece_id] = true
		_expect(tray.has_piece_id(piece_id), "Tray should confirm spawned IDs through lookup")
		_expect(tray.get_piece_by_id(piece_id) != null, "Tray should return piece instances by ID")

	tray.queue_free()

func test_reset_pieces_to_spawn_positions_restores_layout() -> void:
	var tray := PieceTrayScene.instantiate() as PieceTrayController
	_expect(tray != null, "Expected PieceTray scene to instantiate for reset checks")
	if tray == null:
		return

	tray._ready()
	var first_piece_id := tray.get_piece_ids()[0]
	var first_piece := tray.get_piece_by_id(first_piece_id)
	_expect(first_piece != null, "Expected first tray piece to exist for reset checks")
	if first_piece == null:
		tray.queue_free()
		return

	var original_position := first_piece.position
	first_piece.position = original_position + Vector2(91, 47)
	tray.reset_pieces_to_spawn_positions()

	_expect(first_piece.position == original_position, "Expected reset to restore moved tray piece to its spawn position")
	tray.queue_free()

func _canonical_piece_ids() -> Array[String]:
	var ids: Array[String] = []
	for piece in PieceSet.list_all_pieces():
		ids.append(String(piece.get("id", "")))
	return ids

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
