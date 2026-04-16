class_name BoardModel
extends RefCounted

## Coordinate convention:
## - Coordinates are stored as Vector2i(column, row).
## - (0, 0) is the top-left of the board grid.
## - This board uses a fixed 7x8 grid.

enum CellCategory {
	MONTH,
	DATE,
	WEEKDAY,
	MISSING,
}

const GRID_WIDTH := 7
const GRID_HEIGHT := 8
const MISSING_TOKEN := "."

const _ROWS := [
	["Jan", "Feb", "Mar", "Apr", "May", "Jun", MISSING_TOKEN],
	["Jul", "Aug", "Sep", "Oct", "Nov", "Dec", MISSING_TOKEN],
	["1", "2", "3", "4", "5", "6", "7"],
	["8", "9", "10", "11", "12", "13", "14"],
	["15", "16", "17", "18", "19", "20", "21"],
	["22", "23", "24", "25", "26", "27", "28"],
	["29", "30", "31", "Mon", "Tue", "Wed", "Thu"],
	[MISSING_TOKEN, MISSING_TOKEN, MISSING_TOKEN, MISSING_TOKEN, "Fri", "Sat", "Sun"],
]

const _MONTH_LABELS := {
	"Jan": true, "Feb": true, "Mar": true, "Apr": true, "May": true, "Jun": true,
	"Jul": true, "Aug": true, "Sep": true, "Oct": true, "Nov": true, "Dec": true,
}

const _WEEKDAY_LABELS := {
	"Sun": true, "Mon": true, "Tue": true, "Wed": true, "Thu": true, "Fri": true, "Sat": true,
}

static var _cells_cache: Array[Dictionary]
static var _cells_by_coordinate_cache: Dictionary

static func get_all_cells() -> Array[Dictionary]:
	_ensure_cache()
	return _cells_cache.duplicate(true)

static func coordinate_exists(coordinate: Vector2i) -> bool:
	_ensure_cache()
	return _cells_by_coordinate_cache.has(coordinate)

static func get_cell(coordinate: Vector2i) -> Dictionary:
	_ensure_cache()
	if not _cells_by_coordinate_cache.has(coordinate):
		return {}
	return (_cells_by_coordinate_cache[coordinate] as Dictionary).duplicate(true)

static func get_playable_coordinates() -> Array[Vector2i]:
	_ensure_cache()
	var coordinates: Array[Vector2i] = []
	for cell in _cells_cache:
		if cell["playable"]:
			coordinates.append(cell["coordinate"])
	return coordinates

static func get_cells_by_category(category: int) -> Array[Dictionary]:
	_ensure_cache()
	var filtered: Array[Dictionary] = []
	for cell in _cells_cache:
		if cell["category"] == category:
			filtered.append((cell as Dictionary).duplicate(true))
	return filtered

static func _ensure_cache() -> void:
	if _cells_cache != null and _cells_by_coordinate_cache != null:
		return

	_cells_cache = []
	_cells_by_coordinate_cache = {}

	for row_index in range(_ROWS.size()):
		var row: Array = _ROWS[row_index]
		for column_index in range(row.size()):
			var label := row[column_index] as String
			var coordinate := Vector2i(column_index, row_index)
			var category := _category_for_label(label)
			var playable := category != CellCategory.MISSING
			var cell := {
				"coordinate": coordinate,
				"label": label,
				"category": category,
				"playable": playable,
			}
			_cells_cache.append(cell)
			_cells_by_coordinate_cache[coordinate] = cell

static func _category_for_label(label: String) -> CellCategory:
	if label == MISSING_TOKEN:
		return CellCategory.MISSING
	if _MONTH_LABELS.has(label):
		return CellCategory.MONTH
	if _WEEKDAY_LABELS.has(label):
		return CellCategory.WEEKDAY
	return CellCategory.DATE
