extends RefCounted

const BoardDropTargeting = preload("res://model/board/board_drop_targeting.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_grid_coordinate_conversion_for_in_bounds_point()
	test_grid_coordinate_conversion_rejects_out_of_bounds_point()
	test_transformed_local_tiles_map_to_board_coordinates_using_anchor()
	test_preview_coordinate_generation_uses_anchor_and_transformed_tiles()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_grid_coordinate_conversion_for_in_bounds_point() -> void:
	var result := BoardDropTargeting.local_position_to_grid_coordinate(
		Vector2(121.0, 167.0),
		Vector2(52, 52),
		Vector2(4, 4),
		7,
		8
	)
	_expect(result.get("is_over_board", false), "Expected in-bounds local point to map to grid coordinate")
	_expect(result.get("coordinate", Vector2i(-1, -1)) == Vector2i(2, 2), "Expected local point to map to coordinate (2,2)")

func test_grid_coordinate_conversion_rejects_out_of_bounds_point() -> void:
	var off_board := BoardDropTargeting.local_position_to_grid_coordinate(
		Vector2(-3.0, 22.0),
		Vector2(52, 52),
		Vector2(4, 4),
		7,
		8
	)
	_expect(not off_board.get("is_over_board", false), "Expected negative local point to be outside board")

	var beyond_grid := BoardDropTargeting.local_position_to_grid_coordinate(
		Vector2(1000.0, 1000.0),
		Vector2(52, 52),
		Vector2(4, 4),
		7,
		8
	)
	_expect(not beyond_grid.get("is_over_board", false), "Expected distant local point to be outside board")

func test_transformed_local_tiles_map_to_board_coordinates_using_anchor() -> void:
	var local_tiles: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1)]
	var mapped := BoardDropTargeting.transformed_tiles_to_board_coordinates(local_tiles, Vector2i(3, 4))
	_expect(mapped == [Vector2i(3, 4), Vector2i(4, 4), Vector2i(4, 5)], "Expected transformed local tiles to offset by anchor")

func test_preview_coordinate_generation_uses_anchor_and_transformed_tiles() -> void:
	var candidate_anchor := BoardDropTargeting.local_position_to_grid_coordinate(
		Vector2(57.0, 57.0),
		Vector2(52, 52),
		Vector2(4, 4),
		7,
		8
	)
	if not candidate_anchor.get("is_over_board", false):
		_expect(false, "Expected candidate anchor point to be on board")
		return

	var preview := BoardDropTargeting.transformed_tiles_to_board_coordinates(
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)],
		candidate_anchor["coordinate"]
	)
	_expect(preview == [Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)], "Expected preview coordinates to be generated from anchor plus transformed tiles")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
