class_name PlacementValidator
extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")
const BoardDropTargeting = preload("res://model/board/board_drop_targeting.gd")

const FAILURE_NONE := "none"
const FAILURE_OUT_OF_BOUNDS := "out_of_bounds"
const FAILURE_NON_PLAYABLE := "non_playable"
const FAILURE_OCCUPIED := "occupied"
const FAILURE_PROTECTED := "protected"

static func validate_transformed_placement(local_tiles: Array[Vector2i], anchor: Vector2i, occupied_coordinates: Array[Vector2i], protected_coordinates: Array[Vector2i]) -> Dictionary:
	var covered_coordinates := BoardDropTargeting.transformed_tiles_to_board_coordinates(local_tiles, anchor)
	var occupied_lookup := _coordinates_to_lookup(occupied_coordinates)
	var protected_lookup := _coordinates_to_lookup(protected_coordinates)

	for coordinate in covered_coordinates:
		if not BoardModel.coordinate_exists(coordinate):
			return _result(false, FAILURE_OUT_OF_BOUNDS, covered_coordinates)

	for coordinate in covered_coordinates:
		var cell := BoardModel.get_cell(coordinate)
		if not bool(cell.get("playable", false)):
			return _result(false, FAILURE_NON_PLAYABLE, covered_coordinates)

	for coordinate in covered_coordinates:
		if occupied_lookup.has(coordinate):
			return _result(false, FAILURE_OCCUPIED, covered_coordinates)

	for coordinate in covered_coordinates:
		if protected_lookup.has(coordinate):
			return _result(false, FAILURE_PROTECTED, covered_coordinates)

	return _result(true, FAILURE_NONE, covered_coordinates)

static func _coordinates_to_lookup(coordinates: Array[Vector2i]) -> Dictionary:
	var lookup := {}
	for coordinate in coordinates:
		lookup[coordinate] = true
	return lookup

static func _result(valid: bool, failure_reason: String, covered_coordinates: Array[Vector2i]) -> Dictionary:
	return {
		"valid": valid,
		"failure_reason": failure_reason,
		"covered_coordinates": covered_coordinates.duplicate(),
	}
