class_name PieceController
extends Control

const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceTransform = preload("res://model/pieces/piece_transform.gd")

@export var tile_size: float = 32.0
@export var tile_color: Color = Color("#B87333")

@onready var _tile_root: Control = %TileRoot

var _piece_id: String = ""
var _base_tiles: Array[Vector2i] = []
var _transformed_tiles: Array[Vector2i] = []
var _allowed_rotations: Array[int] = [0]
var _allow_flip := false
var _transform_state := {"rotation": 0, "flipped": false}

var _is_dragging := false
var _is_selected := false
var _drag_pointer_offset := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE

func initialize_from_piece_data(piece_data: Dictionary) -> void:
	_piece_id = String(piece_data.get("id", ""))
	_base_tiles = PieceSet.normalize_tiles(_read_tile_offsets(piece_data.get("tiles", [])))

	var transform_data: Dictionary = piece_data.get("transform", {})
	_allowed_rotations = _sanitize_allowed_rotations(transform_data.get("allowed_rotations", [0]))
	_allow_flip = bool(transform_data.get("allow_mirror", false))

	_transform_state = {
		"rotation": _allowed_rotations[0],
		"flipped": false,
	}

	var display_data: Dictionary = piece_data.get("display", {})
	if display_data.has("color"):
		tile_color = Color(str(display_data["color"]))

	_apply_transform_and_refresh_visuals()

func get_piece_id() -> String:
	return _piece_id

func get_transform_state() -> Dictionary:
	return _transform_state.duplicate(true)

func get_current_local_tile_coordinates() -> Array[Vector2i]:
	return _transformed_tiles.duplicate()

func is_flip_allowed() -> bool:
	return _allow_flip

func get_allowed_rotations() -> Array[int]:
	return _allowed_rotations.duplicate()

func is_dragging() -> bool:
	return _is_dragging

func begin_drag(pointer_global_position: Vector2) -> void:
	_is_dragging = true
	_is_selected = true
	_drag_pointer_offset = global_position - pointer_global_position

func continue_drag(pointer_global_position: Vector2) -> void:
	if not _is_dragging:
		return
	global_position = pointer_global_position + _drag_pointer_offset

func end_drag() -> void:
	_is_dragging = false

func rotate_clockwise() -> bool:
	if _allowed_rotations.size() <= 1:
		return false

	var current_rotation: int = int(_transform_state["rotation"])
	var current_index := _allowed_rotations.find(current_rotation)
	if current_index == -1:
		current_index = 0
	var next_index := (current_index + 1) % _allowed_rotations.size()
	_transform_state["rotation"] = _allowed_rotations[next_index]
	_apply_transform_and_refresh_visuals()
	return true

func flip_piece() -> bool:
	if not _allow_flip:
		return false
	_transform_state["flipped"] = not bool(_transform_state["flipped"])
	_apply_transform_and_refresh_visuals()
	return true

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			begin_drag(event.global_position)
			accept_event()
			return
		end_drag()
		accept_event()

func _input(event: InputEvent) -> void:
	if _is_dragging and event is InputEventMouseMotion:
		continue_drag(event.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_selected:
		return
	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_R:
		if rotate_clockwise():
			accept_event()
	elif event.keycode == KEY_F:
		if flip_piece():
			accept_event()

func _apply_transform_and_refresh_visuals() -> void:
	var transformed: Array[Vector2i] = _base_tiles.duplicate()
	if bool(_transform_state["flipped"]):
		transformed = PieceTransform.mirror_tiles(transformed)

	var rotation_turns := int(_transform_state["rotation"]) / 90
	transformed = PieceTransform.rotate_tiles_90(transformed, rotation_turns)
	_transformed_tiles = PieceTransform.normalize_tiles(transformed)

	_rebuild_tile_nodes()

func _rebuild_tile_nodes() -> void:
	for child in _tile_root.get_children():
		child.queue_free()

	var max_x := 0
	var max_y := 0
	for tile in _transformed_tiles:
		var tile_visual := ColorRect.new()
		tile_visual.color = tile_color
		tile_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_visual.position = Vector2(tile.x, tile.y) * tile_size
		tile_visual.custom_minimum_size = Vector2(tile_size, tile_size)
		tile_visual.size = Vector2(tile_size, tile_size)
		_tile_root.add_child(tile_visual)

		max_x = maxi(max_x, tile.x)
		max_y = maxi(max_y, tile.y)

	var width := float(max_x + 1) * tile_size
	var height := float(max_y + 1) * tile_size
	size = Vector2(width, height)
	custom_minimum_size = size
	_tile_root.size = size

func _sanitize_allowed_rotations(raw_rotations: Array) -> Array[int]:
	var sanitized: Array[int] = []
	for rotation in raw_rotations:
		var normalized := posmod(int(rotation), 360)
		if normalized % 90 != 0:
			continue
		if sanitized.has(normalized):
			continue
		sanitized.append(normalized)

	if sanitized.is_empty():
		sanitized.append(0)

	sanitized.sort()
	return sanitized

func _read_tile_offsets(raw_tiles: Array) -> Array[Vector2i]:
	var tile_offsets: Array[Vector2i] = []
	for tile in raw_tiles:
		if tile is Vector2i:
			tile_offsets.append(tile)
	return tile_offsets
