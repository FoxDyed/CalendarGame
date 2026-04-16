class_name FoundationValidator
extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")
const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceTransform = preload("res://model/pieces/piece_transform.gd")
const DailyTargetSelector = preload("res://model/targets/daily_target_selector.gd")

static func validate_foundational_data_for_date_parts(year: int, month: int, day: int) -> Dictionary:
	var board_errors := validate_board_integrity()
	var piece_errors := validate_piece_integrity()
	var target_errors := validate_target_integrity_for_date_parts(year, month, day)

	var all_errors: Array[Dictionary] = []
	for validation_errors in [board_errors, piece_errors, target_errors]:
		for validation_error in validation_errors:
			all_errors.append(validation_error)

	return {
		"ok": all_errors.is_empty(),
		"errors": all_errors,
		"board_errors": board_errors,
		"piece_errors": piece_errors,
		"target_errors": target_errors,
	}

static func validate_board_integrity(cells: Array = []) -> Array[Dictionary]:
	var source_cells: Array = cells
	if source_cells.is_empty():
		source_cells = BoardModel.get_all_cells()

	var errors: Array[Dictionary] = []
	var seen_coordinates := {}
	var duplicate_coordinates: Array = []
	var month_count := 0
	var date_count := 0
	var weekday_count := 0

	for cell in source_cells:
		if not (cell is Dictionary) or not (cell as Dictionary).has("coordinate"):
			errors.append(_error("board", "missing_coordinate", "Board cell is missing required coordinate field", {"cell": cell}))
			continue

		var typed_cell := cell as Dictionary
		var coordinate = typed_cell["coordinate"]
		if seen_coordinates.has(coordinate):
			duplicate_coordinates.append(coordinate)
		else:
			seen_coordinates[coordinate] = true

		if not typed_cell.has("category"):
			errors.append(_error("board", "missing_category", "Board cell is missing required category field", {"coordinate": coordinate}))
			continue

		match int(typed_cell["category"]):
			BoardModel.CellCategory.MONTH:
				month_count += 1
			BoardModel.CellCategory.DATE:
				date_count += 1
			BoardModel.CellCategory.WEEKDAY:
				weekday_count += 1

	if not duplicate_coordinates.is_empty():
		errors.append(_error("board", "duplicate_coordinates", "Board contains duplicate coordinates", {"coordinates": duplicate_coordinates}))

	if month_count != 12:
		errors.append(_error("board", "invalid_month_cell_count", "Board must define exactly 12 month cells", {"expected": 12, "actual": month_count}))
	if date_count != 31:
		errors.append(_error("board", "invalid_date_cell_count", "Board must define exactly 31 date cells", {"expected": 31, "actual": date_count}))
	if weekday_count != 7:
		errors.append(_error("board", "invalid_weekday_cell_count", "Board must define exactly 7 weekday cells", {"expected": 7, "actual": weekday_count}))

	return errors

static func validate_piece_integrity(pieces: Array = []) -> Array[Dictionary]:
	var source_pieces: Array = pieces
	if source_pieces.is_empty():
		source_pieces = PieceSet.list_all_pieces()

	var errors: Array[Dictionary] = []
	var seen_ids := {}
	var duplicate_ids: Array[String] = []

	for piece in source_pieces:
		if not (piece is Dictionary):
			errors.append(_error("pieces", "invalid_piece_entry", "Piece entry is not a dictionary", {"piece": piece}))
			continue

		var typed_piece := piece as Dictionary
		var piece_id: String = str(typed_piece.get("id", ""))
		if piece_id.is_empty():
			errors.append(_error("pieces", "missing_piece_id", "Piece is missing an id", {"piece": typed_piece}))
			continue

		if seen_ids.has(piece_id):
			duplicate_ids.append(piece_id)
		else:
			seen_ids[piece_id] = true

		if PieceSet.has_duplicate_local_offsets(typed_piece):
			errors.append(_error("pieces", "duplicate_local_offsets", "Piece contains duplicate local tile offsets", {"piece_id": piece_id}))

		var variant_count := PieceTransform.get_unique_variant_count(typed_piece)
		if variant_count < 1:
			errors.append(_error("pieces", "no_legal_variants", "Piece must produce at least one legal transformed variant", {"piece_id": piece_id}))

	if not duplicate_ids.is_empty():
		errors.append(_error("pieces", "duplicate_piece_ids", "Piece ids must be unique", {"piece_ids": duplicate_ids}))

	return errors

static func validate_target_integrity_for_date_parts(year: int, month: int, day: int, board_cells: Array = [], target_cells: Array = []) -> Array[Dictionary]:
	var source_board_cells: Array = board_cells
	if source_board_cells.is_empty():
		source_board_cells = BoardModel.get_all_cells()

	var coordinate_lookup := {}
	for cell in source_board_cells:
		if cell is Dictionary and (cell as Dictionary).has("coordinate"):
			coordinate_lookup[(cell as Dictionary)["coordinate"]] = true

	var source_targets: Array = target_cells
	if source_targets.is_empty():
		source_targets = DailyTargetSelector.get_target_cells_for_date_parts(year, month, day)

	var errors: Array[Dictionary] = []
	if source_targets.is_empty():
		errors.append(_error("targets", "missing_targets_for_date", "No targets could be resolved for date", {"year": year, "month": month, "day": day}))
		return errors

	if source_targets.size() != 3:
		errors.append(_error("targets", "invalid_target_count", "Target set must contain exactly 3 targets", {"expected": 3, "actual": source_targets.size(), "year": year, "month": month, "day": day}))

	var month_count := 0
	var date_count := 0
	var weekday_count := 0

	for target in source_targets:
		if not (target is Dictionary):
			errors.append(_error("targets", "invalid_target_entry", "Target entry is not a dictionary", {"target": target}))
			continue
		var typed_target := target as Dictionary

		if not typed_target.has("coordinate"):
			errors.append(_error("targets", "missing_target_coordinate", "Target entry is missing coordinate", {"target": typed_target}))
			continue

		var coordinate = typed_target["coordinate"]
		if not coordinate_lookup.has(coordinate):
			errors.append(_error("targets", "target_coordinate_not_on_board", "Target coordinate does not exist on board", {"coordinate": coordinate}))

		if not typed_target.has("category"):
			errors.append(_error("targets", "missing_target_category", "Target entry is missing category", {"coordinate": coordinate}))
			continue

		match int(typed_target["category"]):
			BoardModel.CellCategory.MONTH:
				month_count += 1
			BoardModel.CellCategory.DATE:
				date_count += 1
			BoardModel.CellCategory.WEEKDAY:
				weekday_count += 1
			_:
				errors.append(_error("targets", "invalid_target_category", "Target category must be month, date, or weekday", {"coordinate": coordinate, "category": typed_target["category"]}))

	if month_count != 1:
		errors.append(_error("targets", "invalid_month_target_count", "Target set must include exactly one month target", {"expected": 1, "actual": month_count}))
	if date_count != 1:
		errors.append(_error("targets", "invalid_date_target_count", "Target set must include exactly one date target", {"expected": 1, "actual": date_count}))
	if weekday_count != 1:
		errors.append(_error("targets", "invalid_weekday_target_count", "Target set must include exactly one weekday target", {"expected": 1, "actual": weekday_count}))

	return errors

static func _error(scope: String, code: String, message: String, details: Dictionary = {}) -> Dictionary:
	return {
		"scope": scope,
		"code": code,
		"message": message,
		"details": details,
	}
