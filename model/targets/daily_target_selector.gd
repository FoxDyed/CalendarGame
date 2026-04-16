class_name DailyTargetSelector
extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")

## Weekday indexing uses Gregorian calendar with:
## 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
const _WEEKDAY_LABELS: Array[String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
const _MONTH_LABELS: Array[String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

static func get_target_cells_for_date_parts(year: int, month: int, day: int) -> Array[Dictionary]:
	if not _is_valid_date(year, month, day):
		return []

	var month_label: String = _MONTH_LABELS[month - 1]
	var date_label: String = str(day)
	var weekday_label: String = _WEEKDAY_LABELS[_weekday_index(year, month, day)]

	var month_cell := _find_cell_by_label_and_category(month_label, BoardModel.CellCategory.MONTH)
	var date_cell := _find_cell_by_label_and_category(date_label, BoardModel.CellCategory.DATE)
	var weekday_cell := _find_cell_by_label_and_category(weekday_label, BoardModel.CellCategory.WEEKDAY)

	var targets: Array[Dictionary] = []
	if month_cell.is_empty() or date_cell.is_empty() or weekday_cell.is_empty():
		return targets

	targets.append(month_cell)
	targets.append(date_cell)
	targets.append(weekday_cell)

	if not validate_target_set(targets):
		return []

	return targets

static func get_target_cells_for_date(date_input: Dictionary) -> Array[Dictionary]:
	if not (date_input.has("year") and date_input.has("month") and date_input.has("day")):
		return []
	return get_target_cells_for_date_parts(int(date_input["year"]), int(date_input["month"]), int(date_input["day"]))

static func get_target_coordinates_for_date_parts(year: int, month: int, day: int) -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	for cell in get_target_cells_for_date_parts(year, month, day):
		coordinates.append(cell["coordinate"])
	return coordinates

static func get_target_labels_for_date_parts(year: int, month: int, day: int) -> Dictionary:
	var labels := {
		"month": "",
		"date": "",
		"weekday": "",
	}
	for cell in get_target_cells_for_date_parts(year, month, day):
		match cell["category"]:
			BoardModel.CellCategory.MONTH:
				labels["month"] = cell["label"]
			BoardModel.CellCategory.DATE:
				labels["date"] = cell["label"]
			BoardModel.CellCategory.WEEKDAY:
				labels["weekday"] = cell["label"]
	return labels

static func validate_target_set(target_cells: Array[Dictionary]) -> bool:
	if target_cells.size() != 3:
		return false

	var month_count := 0
	var date_count := 0
	var weekday_count := 0
	var seen_coordinates := {}

	for cell in target_cells:
		if not cell.has("coordinate") or not cell.has("label") or not cell.has("category"):
			return false

		var coordinate: Vector2i = cell["coordinate"]
		if seen_coordinates.has(coordinate):
			return false
		seen_coordinates[coordinate] = true

		if not BoardModel.coordinate_exists(coordinate):
			return false

		var canonical_cell := BoardModel.get_cell(coordinate)
		if canonical_cell.is_empty() or canonical_cell["label"] != cell["label"]:
			return false

		match cell["category"]:
			BoardModel.CellCategory.MONTH:
				month_count += 1
			BoardModel.CellCategory.DATE:
				date_count += 1
			BoardModel.CellCategory.WEEKDAY:
				weekday_count += 1
			_:
				return false

	return month_count == 1 and date_count == 1 and weekday_count == 1

static func _find_cell_by_label_and_category(label: String, category: int) -> Dictionary:
	for cell in BoardModel.get_cells_by_category(category):
		if cell["label"] == label:
			return cell
	return {}

static func _is_valid_date(year: int, month: int, day: int) -> bool:
	if month < 1 or month > 12:
		return false
	if day < 1:
		return false

	var max_day := _days_in_month(year, month)
	return day <= max_day

static func _days_in_month(year: int, month: int) -> int:
	var base_days := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and _is_leap_year(year):
		return 29
	return base_days[month - 1]

static func _is_leap_year(year: int) -> bool:
	if year % 400 == 0:
		return true
	if year % 100 == 0:
		return false
	return year % 4 == 0

static func _weekday_index(year: int, month: int, day: int) -> int:
	# Tomohiko Sakamoto algorithm (Gregorian calendar)
	var month_offsets := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var adjusted_year := year
	if month < 3:
		adjusted_year -= 1
	var weekday_value: int = adjusted_year + int(adjusted_year / 4.0) - int(adjusted_year / 100.0) + int(adjusted_year / 400.0) + int(month_offsets[month - 1]) + day
	return weekday_value % 7
