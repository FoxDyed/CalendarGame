extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")
const DailyTargetSelector = preload("res://model/targets/daily_target_selector.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_known_date_label_mappings()
	test_target_sets_are_exactly_three_cells()
	test_returned_cells_always_exist_on_board()
	test_weekday_mapping_for_known_dates()
	test_date_dictionary_input()
	test_target_set_validator_strictness()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_known_date_label_mappings() -> void:
	var samples := [
		{"y": 2026, "m": 4, "d": 16, "month": "Apr", "date": "16", "weekday": "Thu"},
		{"y": 2024, "m": 2, "d": 29, "month": "Feb", "date": "29", "weekday": "Thu"},
		{"y": 2023, "m": 7, "d": 4, "month": "Jul", "date": "4", "weekday": "Tue"},
	]

	for sample in samples:
		var labels = DailyTargetSelector.get_target_labels_for_date_parts(sample["y"], sample["m"], sample["d"])
		_expect(labels["month"] == sample["month"], "Expected month label %s for %s-%s-%s" % [sample["month"], sample["y"], sample["m"], sample["d"]])
		_expect(labels["date"] == sample["date"], "Expected date label %s for %s-%s-%s" % [sample["date"], sample["y"], sample["m"], sample["d"]])
		_expect(labels["weekday"] == sample["weekday"], "Expected weekday label %s for %s-%s-%s" % [sample["weekday"], sample["y"], sample["m"], sample["d"]])

func test_target_sets_are_exactly_three_cells() -> void:
	var samples := [
		{"y": 2025, "m": 1, "d": 1},
		{"y": 2025, "m": 12, "d": 31},
		{"y": 2024, "m": 2, "d": 29},
		{"y": 2000, "m": 1, "d": 1},
	]

	for sample in samples:
		var cells = DailyTargetSelector.get_target_cells_for_date_parts(sample["y"], sample["m"], sample["d"])
		_expect(cells.size() == 3, "Expected exactly 3 target cells for %s-%s-%s" % [sample["y"], sample["m"], sample["d"]])
		_expect(DailyTargetSelector.validate_target_set(cells), "Expected valid target set for %s-%s-%s" % [sample["y"], sample["m"], sample["d"]])

func test_returned_cells_always_exist_on_board() -> void:
	var samples := [
		{"y": 1999, "m": 12, "d": 31},
		{"y": 2032, "m": 6, "d": 15},
		{"y": 2021, "m": 11, "d": 7},
	]

	for sample in samples:
		for cell in DailyTargetSelector.get_target_cells_for_date_parts(sample["y"], sample["m"], sample["d"]):
			var coordinate: Vector2i = cell["coordinate"]
			_expect(BoardModel.coordinate_exists(coordinate), "Expected coordinate %s to exist on board" % coordinate)
			var canonical = BoardModel.get_cell(coordinate)
			_expect(canonical["label"] == cell["label"], "Expected canonical cell label %s at %s" % [cell["label"], coordinate])

func test_weekday_mapping_for_known_dates() -> void:
	var known_dates := [
		{"y": 2000, "m": 1, "d": 1, "weekday": "Sat"},
		{"y": 2001, "m": 9, "d": 9, "weekday": "Sun"},
		{"y": 2010, "m": 5, "d": 17, "weekday": "Mon"},
		{"y": 1999, "m": 12, "d": 31, "weekday": "Fri"},
		{"y": 2024, "m": 2, "d": 29, "weekday": "Thu"},
		{"y": 2026, "m": 4, "d": 16, "weekday": "Thu"},
	]

	for sample in known_dates:
		var labels = DailyTargetSelector.get_target_labels_for_date_parts(sample["y"], sample["m"], sample["d"])
		_expect(labels["weekday"] == sample["weekday"], "Expected weekday %s for %s-%s-%s" % [sample["weekday"], sample["y"], sample["m"], sample["d"]])

func test_date_dictionary_input() -> void:
	var cells = DailyTargetSelector.get_target_cells_for_date({"year": 2023, "month": 10, "day": 31})
	_expect(cells.size() == 3, "Expected date dictionary input to produce exactly 3 cells")
	var labels = DailyTargetSelector.get_target_labels_for_date_parts(2023, 10, 31)
	_expect(labels["month"] == "Oct", "Expected Oct for 2023-10-31")
	_expect(labels["date"] == "31", "Expected 31 for 2023-10-31")
	_expect(labels["weekday"] == "Tue", "Expected Tuesday for 2023-10-31")

func test_target_set_validator_strictness() -> void:
	var valid = DailyTargetSelector.get_target_cells_for_date_parts(2025, 3, 15)
	_expect(DailyTargetSelector.validate_target_set(valid), "Expected normal target set to be valid")

	var wrong_count: Array[Dictionary] = [valid[0], valid[1]]
	_expect(not DailyTargetSelector.validate_target_set(wrong_count), "Expected target set with 2 cells to be invalid")

	var duplicate_category = [valid[0], valid[0], valid[2]]
	_expect(not DailyTargetSelector.validate_target_set(duplicate_category), "Expected duplicate month category to be invalid")

	var invalid_coordinate_cell = valid[0].duplicate(true)
	invalid_coordinate_cell["coordinate"] = Vector2i(99, 99)
	var invalid_target = [invalid_coordinate_cell, valid[1], valid[2]]
	_expect(not DailyTargetSelector.validate_target_set(invalid_target), "Expected unknown coordinate to be invalid")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
