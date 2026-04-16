extends RefCounted

const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceTransform = preload("res://model/pieces/piece_transform.gd")
const PieceScene = preload("res://scenes/pieces/piece_scene.tscn")

var _failures: Array[String] = []

func run_all() -> bool:
	test_initialization_from_piece_definition_sets_expected_state()
	test_rotation_updates_transformed_tile_layout()
	test_flip_respects_piece_permissions()
	test_drag_state_transitions_are_consistent()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_initialization_from_piece_definition_sets_expected_state() -> void:
	var piece := _instantiate_piece("L5")
	_expect(piece.get_piece_id() == "L5", "Piece ID should be initialized from piece definition")
	_expect(piece.get_transform_state() == {"rotation": 0, "flipped": false}, "Piece should start with default transform state")
	_expect(piece.get_allowed_rotations() == [0, 90, 180, 270], "Allowed rotations should be exposed from definition")
	_expect(piece.is_flip_allowed(), "Mirror-enabled piece should expose flip permission")
	_expect(piece.get_current_local_tile_coordinates() == PieceSet.normalize_tiles(_piece_data("L5")["tiles"]), "Initial tile coordinates should match normalized canonical tiles")
	piece.queue_free()

func test_rotation_updates_transformed_tile_layout() -> void:
	var piece := _instantiate_piece("L5")
	var rotated := piece.rotate_clockwise()
	_expect(rotated, "Rotate action should succeed for piece with multiple allowed rotations")

	var expected := PieceTransform.normalize_tiles(PieceTransform.rotate_tiles_90(_piece_data("L5")["tiles"], 1))
	_expect(piece.get_transform_state()["rotation"] == 90, "Rotation state should advance to next allowed value")
	_expect(piece.get_current_local_tile_coordinates() == expected, "Rotating should update transformed tile coordinates")
	piece.queue_free()

func test_flip_respects_piece_permissions() -> void:
	var non_flippable := _instantiate_piece("T5")
	_expect(not non_flippable.flip_piece(), "Flip action should fail when mirror is not allowed")
	_expect(not non_flippable.get_transform_state()["flipped"], "Transform state should remain unflipped when mirror is disallowed")
	non_flippable.queue_free()

	var flippable := _instantiate_piece("L5")
	_expect(flippable.flip_piece(), "Flip action should succeed when mirror is allowed")
	_expect(flippable.get_transform_state()["flipped"], "Transform state should be flipped after a successful flip")
	flippable.queue_free()

func test_drag_state_transitions_are_consistent() -> void:
	var piece := _instantiate_piece("U5")
	piece.global_position = Vector2(100, 140)

	piece.begin_drag(Vector2(120, 170))
	_expect(piece.is_dragging(), "Piece should enter dragging state when drag begins")

	piece.continue_drag(Vector2(160, 220))
	_expect(piece.global_position == Vector2(140, 190), "Piece should follow pointer movement with preserved offset during drag")

	piece.end_drag()
	_expect(not piece.is_dragging(), "Piece should exit dragging state when drag ends")
	piece.queue_free()

func _instantiate_piece(piece_id: String) -> PieceController:
	var instance := PieceScene.instantiate() as PieceController
	instance.initialize_from_piece_data(_piece_data(piece_id))
	return instance

func _piece_data(piece_id: String) -> Dictionary:
	for piece in PieceSet.list_all_pieces():
		if piece["id"] == piece_id:
			return piece
	return {}

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
