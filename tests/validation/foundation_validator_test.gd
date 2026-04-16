extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")
const PieceSet = preload("res://model/pieces/piece_set.gd")
const DailyTargetSelector = preload("res://model/targets/daily_target_selector.gd")
const FoundationValidator = preload("res://model/validation/foundation_validator.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_validate_foundational_data_success_case()
	test_board_integrity_failure_reports_structured_errors()
	test_piece_integrity_failure_reports_structured_errors()
	test_target_integrity_failure_reports_structured_errors()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_validate_foundational_data_success_case() -> void:
	var result = FoundationValidator.validate_foundational_data_for_date_parts(2026, 4, 16)
	_expect(result["ok"], "Expected full validation to pass on canonical data")
	_expect((result["errors"] as Array).is_empty(), "Expected no aggregate errors on canonical data")
	_expect((result["board_errors"] as Array).is_empty(), "Expected no board errors on canonical data")
	_expect((result["piece_errors"] as Array).is_empty(), "Expected no piece errors on canonical data")
	_expect((result["target_errors"] as Array).is_empty(), "Expected no target errors on canonical data")

func test_board_integrity_failure_reports_structured_errors() -> void:
	var invalid_cells = BoardModel.get_all_cells()
	invalid_cells.append(invalid_cells[0].duplicate(true))

	var board_errors = FoundationValidator.validate_board_integrity(invalid_cells)
	_expect(board_errors.size() >= 1, "Expected board validation to fail for duplicate coordinate")
	_expect(_contains_error_code(board_errors, "duplicate_coordinates"), "Expected duplicate_coordinates board error code")
	_expect(_all_structured_errors(board_errors), "Expected board errors to be structured")

func test_piece_integrity_failure_reports_structured_errors() -> void:
	var invalid_pieces = PieceSet.list_all_pieces()
	var duplicate_id_piece = (invalid_pieces[0] as Dictionary).duplicate(true)
	invalid_pieces.append(duplicate_id_piece)

	var zero_variant_piece := {
		"id": "BROKEN_ZERO_VARIANT",
		"tiles": [Vector2i(0, 0)],
		"transform": {"allowed_rotations": [], "allow_mirror": false},
	}
	invalid_pieces.append(zero_variant_piece)

	var duplicate_offsets_piece := {
		"id": "BROKEN_DUPLICATE_OFFSETS",
		"tiles": [Vector2i(0, 0), Vector2i(0, 0)],
		"transform": {"allowed_rotations": [0], "allow_mirror": false},
	}
	invalid_pieces.append(duplicate_offsets_piece)

	var piece_errors = FoundationValidator.validate_piece_integrity(invalid_pieces)
	_expect(piece_errors.size() >= 3, "Expected piece validation to surface multiple failures")
	_expect(_contains_error_code(piece_errors, "duplicate_piece_ids"), "Expected duplicate_piece_ids error code")
	_expect(_contains_error_code(piece_errors, "no_legal_variants"), "Expected no_legal_variants error code")
	_expect(_contains_error_code(piece_errors, "duplicate_local_offsets"), "Expected duplicate_local_offsets error code")
	_expect(_all_structured_errors(piece_errors), "Expected piece errors to be structured")

func test_target_integrity_failure_reports_structured_errors() -> void:
	var board_cells = BoardModel.get_all_cells()
	var canonical_targets = DailyTargetSelector.get_target_cells_for_date_parts(2026, 4, 16)
	var invalid_targets: Array = []

	var duplicate_month = (canonical_targets[0] as Dictionary).duplicate(true)
	invalid_targets.append(duplicate_month)
	invalid_targets.append((canonical_targets[0] as Dictionary).duplicate(true))

	var unknown_coordinate_target = (canonical_targets[1] as Dictionary).duplicate(true)
	unknown_coordinate_target["coordinate"] = Vector2i(99, 99)
	invalid_targets.append(unknown_coordinate_target)

	var target_errors = FoundationValidator.validate_target_integrity_for_date_parts(2026, 4, 16, board_cells, invalid_targets)
	_expect(target_errors.size() >= 3, "Expected target validation to surface multiple failures")
	_expect(_contains_error_code(target_errors, "target_coordinate_not_on_board"), "Expected target_coordinate_not_on_board error code")
	_expect(_contains_error_code(target_errors, "invalid_month_target_count"), "Expected invalid_month_target_count error code")
	_expect(_contains_error_code(target_errors, "invalid_weekday_target_count"), "Expected invalid_weekday_target_count error code")
	_expect(_all_structured_errors(target_errors), "Expected target errors to be structured")

func _contains_error_code(errors: Array[Dictionary], code: String) -> bool:
	for validation_error in errors:
		if validation_error.get("code", "") == code:
			return true
	return false

func _all_structured_errors(errors: Array[Dictionary]) -> bool:
	for validation_error in errors:
		if not validation_error.has("scope"):
			return false
		if not validation_error.has("code"):
			return false
		if not validation_error.has("message"):
			return false
		if not validation_error.has("details"):
			return false
	return true

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
