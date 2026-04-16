extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_month_cell_count()
	test_date_cell_count()
	test_weekday_cell_count()
	test_coordinate_uniqueness()
	test_helper_query_counts()
	test_sample_label_coordinates()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_month_cell_count() -> void:
	_expect(BoardModel.get_cells_by_category(BoardModel.CellCategory.MONTH).size() == 12, "Expected exactly 12 month cells")

func test_date_cell_count() -> void:
	_expect(BoardModel.get_cells_by_category(BoardModel.CellCategory.DATE).size() == 31, "Expected exactly 31 date cells")

func test_weekday_cell_count() -> void:
	_expect(BoardModel.get_cells_by_category(BoardModel.CellCategory.WEEKDAY).size() == 7, "Expected exactly 7 weekday cells")

func test_coordinate_uniqueness() -> void:
	var seen := {}
	for cell in BoardModel.get_all_cells():
		var coordinate: Vector2i = cell["coordinate"]
		_expect(not seen.has(coordinate), "Duplicate coordinate found: %s" % coordinate)
		seen[coordinate] = true

func test_helper_query_counts() -> void:
	_expect(BoardModel.get_all_cells().size() == 56, "Expected 56 total board coordinates in a 7x8 grid")
	_expect(BoardModel.get_cells_by_category(BoardModel.CellCategory.MISSING).size() == 6, "Expected 6 missing cells")
	_expect(BoardModel.get_playable_coordinates().size() == 50, "Expected 50 playable coordinates")
	_expect(BoardModel.coordinate_exists(Vector2i(0, 0)), "Expected coordinate (0,0) to exist")
	_expect(BoardModel.coordinate_exists(Vector2i(6, 7)), "Expected coordinate (6,7) to exist")
	_expect(not BoardModel.coordinate_exists(Vector2i(7, 0)), "Expected coordinate (7,0) to be outside the board")

func test_sample_label_coordinates() -> void:
	_expect(BoardModel.get_cell(Vector2i(0, 0))["label"] == "Jan", "Expected Jan at (0,0)")
	_expect(BoardModel.get_cell(Vector2i(5, 1))["label"] == "Dec", "Expected Dec at (5,1)")
	_expect(BoardModel.get_cell(Vector2i(0, 6))["label"] == "29", "Expected 29 at (0,6)")
	_expect(BoardModel.get_cell(Vector2i(3, 6))["label"] == "Mon", "Expected Mon at (3,6)")
	_expect(BoardModel.get_cell(Vector2i(6, 7))["label"] == "Sun", "Expected Sun at (6,7)")
	_expect(BoardModel.get_cell(Vector2i(6, 0))["playable"] == false, "Expected missing cell at (6,0)")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
