class_name BoardView
extends Control

const BoardModel = preload("res://model/board/board_model.gd")
const BoardDropTargeting = preload("res://model/board/board_drop_targeting.gd")

const CELL_SIZE := Vector2(52, 52)
const CELL_GAP := Vector2(4, 4)

const COLOR_EMPTY := Color("#3c5a9a")
const COLOR_MISSING := Color("#1f1f1f")
const COLOR_PROTECTED := Color("#2f8f4e")
const COLOR_OCCUPIED := Color("#b36a22")
const COLOR_PREVIEW := Color("#f0d35b")
const COLOR_TEXT := Color("#f2f2f2")

var _protected_targets: Dictionary = {}
var _occupied_coordinates: Dictionary = {}
var _preview_coordinates: Dictionary = {}
var _rendered_cells_by_coordinate: Dictionary = {}

func _ready() -> void:
	refresh_board()

func set_protected_target_cells(coordinates: Array[Vector2i]) -> void:
	_protected_targets = _coordinates_to_lookup(coordinates)
	refresh_board()

func set_occupied_coordinates(coordinates: Array[Vector2i]) -> void:
	_occupied_coordinates = _coordinates_to_lookup(coordinates)
	refresh_board()

func set_preview_coordinates(coordinates: Array[Vector2i]) -> void:
	_preview_coordinates = _coordinates_to_lookup(coordinates)
	refresh_board()

func clear_preview() -> void:
	if _preview_coordinates.is_empty():
		return
	_preview_coordinates.clear()
	refresh_board()

func get_preview_coordinates() -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	for coordinate in _preview_coordinates.keys():
		coordinates.append(coordinate)
	coordinates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y
	)
	return coordinates

func clear_occupancy() -> void:
	_occupied_coordinates.clear()
	refresh_board()

func refresh_board() -> void:
	var grid_root := _get_grid_root()
	if grid_root == null:
		return

	for child in grid_root.get_children():
		child.queue_free()

	_rendered_cells_by_coordinate.clear()

	for cell in BoardModel.get_all_cells():
		var coordinate: Vector2i = cell["coordinate"]
		var cell_view := _build_cell_view(cell)
		grid_root.add_child(cell_view)
		_rendered_cells_by_coordinate[coordinate] = {
			"state": _resolve_cell_state(cell),
			"view": cell_view,
		}

	custom_minimum_size = _calculate_board_size()
	grid_root.custom_minimum_size = custom_minimum_size

func get_rendered_cell_count() -> int:
	return _rendered_cells_by_coordinate.size()

func is_protected_coordinate(coordinate: Vector2i) -> bool:
	return _protected_targets.has(coordinate)

func is_occupied_coordinate(coordinate: Vector2i) -> bool:
	return _occupied_coordinates.has(coordinate)

func get_cell_render_state(coordinate: Vector2i) -> String:
	if not _rendered_cells_by_coordinate.has(coordinate):
		return ""
	return _rendered_cells_by_coordinate[coordinate]["state"] as String

func try_global_position_to_grid_coordinate(pointer_global_position: Vector2) -> Dictionary:
	var local_position := get_global_transform_with_canvas().affine_inverse() * pointer_global_position
	return BoardDropTargeting.local_position_to_grid_coordinate(
		local_position,
		CELL_SIZE,
		CELL_GAP,
		BoardModel.GRID_WIDTH,
		BoardModel.GRID_HEIGHT
	)

func transformed_local_tiles_to_board_coordinates(local_tiles: Array[Vector2i], anchor: Vector2i) -> Array[Vector2i]:
	return BoardDropTargeting.transformed_tiles_to_board_coordinates(local_tiles, anchor)

func _build_cell_view(cell: Dictionary) -> Control:
	var coordinate: Vector2i = cell["coordinate"]
	var state := _resolve_cell_state(cell)

	var rect := ColorRect.new()
	rect.name = "Cell_%d_%d" % [coordinate.x, coordinate.y]
	rect.custom_minimum_size = CELL_SIZE
	rect.position = _grid_to_position(coordinate)
	rect.color = _color_for_state(state)

	var label := Label.new()
	label.text = cell["label"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_right = 1.0
	label.anchor_bottom = 1.0
	label.modulate = COLOR_TEXT
	rect.add_child(label)

	return rect

func _resolve_cell_state(cell: Dictionary) -> String:
	var coordinate: Vector2i = cell["coordinate"]
	if not cell["playable"]:
		return "missing"
	if _preview_coordinates.has(coordinate):
		return "preview"
	if _occupied_coordinates.has(coordinate):
		return "occupied"
	if _protected_targets.has(coordinate):
		return "protected"
	return "empty"

func _color_for_state(state: String) -> Color:
	match state:
		"missing":
			return COLOR_MISSING
		"preview":
			return COLOR_PREVIEW
		"occupied":
			return COLOR_OCCUPIED
		"protected":
			return COLOR_PROTECTED
		_:
			return COLOR_EMPTY

func _grid_to_position(coordinate: Vector2i) -> Vector2:
	return Vector2(
		coordinate.x * (CELL_SIZE.x + CELL_GAP.x),
		coordinate.y * (CELL_SIZE.y + CELL_GAP.y)
	)

func _calculate_board_size() -> Vector2:
	return Vector2(
		BoardModel.GRID_WIDTH * CELL_SIZE.x + (BoardModel.GRID_WIDTH - 1) * CELL_GAP.x,
		BoardModel.GRID_HEIGHT * CELL_SIZE.y + (BoardModel.GRID_HEIGHT - 1) * CELL_GAP.y
	)

func _get_grid_root() -> Control:
	return get_node_or_null("GridRoot") as Control

func _coordinates_to_lookup(coordinates: Array[Vector2i]) -> Dictionary:
	var lookup := {}
	for coordinate in coordinates:
		lookup[coordinate] = true
	return lookup
