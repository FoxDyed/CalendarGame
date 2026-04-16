extends RefCounted

const PlacementValidator = preload("res://model/validation/placement_validator.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_valid_placement()
	test_out_of_bounds_placement()
	test_overlap_with_occupied_cells()
	test_coverage_of_protected_targets()
	test_non_playable_cell_coverage()
	test_repeated_evaluation_is_deterministic()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_valid_placement() -> void:
	var result := PlacementValidator.validate_transformed_placement(
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
		Vector2i(2, 2),
		[],
		[]
	)
	_expect(result["valid"], "Expected placement to be valid")
	_expect(result["failure_reason"] == PlacementValidator.FAILURE_NONE, "Expected valid placement to have none failure reason")
	_expect(result["covered_coordinates"] == [Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3)], "Expected covered coordinates from anchor plus transformed offsets")

func test_out_of_bounds_placement() -> void:
	var result := PlacementValidator.validate_transformed_placement(
		[Vector2i(0, 0), Vector2i(1, 0)],
		Vector2i(6, 7),
		[],
		[]
	)
	_expect(not result["valid"], "Expected placement extending beyond board to be invalid")
	_expect(result["failure_reason"] == PlacementValidator.FAILURE_OUT_OF_BOUNDS, "Expected out-of-bounds failure reason")

func test_overlap_with_occupied_cells() -> void:
	var result := PlacementValidator.validate_transformed_placement(
		[Vector2i(0, 0), Vector2i(1, 0)],
		Vector2i(2, 2),
		[Vector2i(3, 2)],
		[]
	)
	_expect(not result["valid"], "Expected overlap with occupied cell to be invalid")
	_expect(result["failure_reason"] == PlacementValidator.FAILURE_OCCUPIED, "Expected occupied failure reason")

func test_coverage_of_protected_targets() -> void:
	var result := PlacementValidator.validate_transformed_placement(
		[Vector2i(0, 0), Vector2i(0, 1)],
		Vector2i(1, 1),
		[],
		[Vector2i(1, 2)]
	)
	_expect(not result["valid"], "Expected covering protected target to be invalid")
	_expect(result["failure_reason"] == PlacementValidator.FAILURE_PROTECTED, "Expected protected failure reason")

func test_non_playable_cell_coverage() -> void:
	var result := PlacementValidator.validate_transformed_placement(
		[Vector2i(0, 0)],
		Vector2i(6, 0),
		[],
		[]
	)
	_expect(not result["valid"], "Expected placement on missing board cell to be invalid")
	_expect(result["failure_reason"] == PlacementValidator.FAILURE_NON_PLAYABLE, "Expected non-playable failure reason")

func test_repeated_evaluation_is_deterministic() -> void:
	var local_tiles: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)]
	var occupied: Array[Vector2i] = [Vector2i(4, 3)]
	var protected: Array[Vector2i] = [Vector2i(1, 1)]

	var first := PlacementValidator.validate_transformed_placement(local_tiles, Vector2i(3, 3), occupied, protected)
	var second := PlacementValidator.validate_transformed_placement(local_tiles, Vector2i(3, 3), occupied, protected)
	_expect(first == second, "Expected repeated placement evaluation to return identical result")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
