extends Control

const PieceTrayController = preload("res://scripts/gameplay/piece_tray_controller.gd")
const BoardView = preload("res://scripts/board/board_view.gd")
const PlacementValidator = preload("res://model/validation/placement_validator.gd")
const DropPlacementState = preload("res://model/gameplay/drop_placement_state.gd")
const DailyTargetSelector = preload("res://model/targets/daily_target_selector.gd")

const DAILY_TEST_DATE := {
	"year": 2026,
	"month": 1,
	"day": 15,
}

@onready var board: Control = %Board
@onready var piece_tray: Control = %PieceTray
@onready var ui_controls: Control = %UIControls
@onready var rotate_hint_label: Label = %RotateHintLabel
@onready var flip_hint_label: Label = %FlipHintLabel
@onready var reset_layout_button: Button = %ResetLayoutButton

var _loaded_piece_count := 0
var _board_state: Dictionary = {}
var _board_view: BoardView
var _piece_tray_controller: PieceTrayController
var _drop_placement_state := DropPlacementState.new()
var _daily_target_cells: Array[Dictionary] = []

func _ready() -> void:
	if board == null or piece_tray == null or ui_controls == null:
		push_error("MainGameplayController is missing required child regions")
		return

	_board_view = board.get_node_or_null("BoardCenter/BoardScene") as BoardView
	_piece_tray_controller = piece_tray.get_node_or_null("TrayContent/PieceTrayScene") as PieceTrayController
	_initialize_single_daily_puzzle()
	_connect_piece_drag_handlers()
	_connect_ui_controls()
	_refresh_transform_hints()

func load_piece_placeholders(piece_definitions: Array[Dictionary]) -> void:
	_loaded_piece_count = piece_definitions.size()
	_set_status_text("Pieces: %d" % _loaded_piece_count)

func update_board_state_placeholder(board_state: Dictionary) -> void:
	_board_state = board_state.duplicate(true)
	_set_status_text("Board state keys: %d" % _board_state.size())

func get_fixed_test_date() -> Dictionary:
	return DAILY_TEST_DATE.duplicate(true)

func get_daily_target_cells() -> Array[Dictionary]:
	return _daily_target_cells.duplicate(true)

func _initialize_single_daily_puzzle() -> void:
	_drop_placement_state.clear_all_placements()
	if _piece_tray_controller != null:
		_piece_tray_controller.populate_from_canonical_piece_set()

	_daily_target_cells = DailyTargetSelector.get_target_cells_for_date(DAILY_TEST_DATE)
	var target_coordinates: Array[Vector2i] = []
	for target_cell in _daily_target_cells:
		target_coordinates.append(target_cell["coordinate"])

	if _board_view != null:
		_board_view.set_protected_target_cells(target_coordinates)
		_board_view.set_occupied_coordinates([])
		_board_view.clear_preview()

	var labels := DailyTargetSelector.get_target_labels_for_date_parts(
		DAILY_TEST_DATE["year"],
		DAILY_TEST_DATE["month"],
		DAILY_TEST_DATE["day"]
	)
	_set_status_text("Date %04d-%02d-%02d • %s %s %s" % [
		DAILY_TEST_DATE["year"],
		DAILY_TEST_DATE["month"],
		DAILY_TEST_DATE["day"],
		labels["month"],
		labels["date"],
		labels["weekday"],
	])

func _connect_piece_drag_handlers() -> void:
	if _piece_tray_controller == null:
		return

	for piece_id in _piece_tray_controller.get_piece_ids():
		var piece := _piece_tray_controller.get_piece_by_id(piece_id)
		if piece == null:
			continue
		if not piece.drag_started.is_connected(_on_piece_drag_started):
			piece.drag_started.connect(_on_piece_drag_started)
		if not piece.drag_moved.is_connected(_on_piece_drag_moved):
			piece.drag_moved.connect(_on_piece_drag_moved)
		if not piece.drag_ended.is_connected(_on_piece_drag_ended):
			piece.drag_ended.connect(_on_piece_drag_ended)

func _on_piece_drag_started(piece: PieceController) -> void:
	if _board_view == null:
		return

	_drop_placement_state.begin_drag(piece.get_piece_id(), piece.global_position)
	_refresh_board_occupancy()
	_on_piece_drag_moved(piece)

func _on_piece_drag_moved(piece: PieceController) -> void:
	if _board_view == null:
		return

	var candidate := _build_drop_candidate(piece)
	if not candidate.get("is_over_board", false):
		_board_view.clear_preview()
		return

	_board_view.set_preview_validation(candidate["validation_result"])

func _on_piece_drag_ended(piece: PieceController) -> void:
	if _board_view == null:
		return

	var candidate := _build_drop_candidate(piece)
	if candidate.get("is_over_board", false) and (candidate["validation_result"] as Dictionary).get("valid", false):
		var validation_result: Dictionary = candidate["validation_result"]
		var anchor: Vector2i = candidate["anchor"]
		var covered_coordinates := validation_result.get("covered_coordinates", []) as Array[Vector2i]
		var snapped_global_position := _board_view.grid_coordinate_to_global_position(anchor)
		piece.global_position = snapped_global_position
		_drop_placement_state.commit_drop(piece.get_piece_id(), anchor, covered_coordinates, snapped_global_position)
	else:
		var rejection := _drop_placement_state.reject_drop(piece.get_piece_id(), piece.global_position)
		piece.global_position = rejection.get("restore_global_position", piece.global_position)

	_refresh_board_occupancy()
	_board_view.clear_preview()

func _build_drop_candidate(piece: PieceController) -> Dictionary:
	var conversion := _board_view.try_global_position_to_grid_coordinate(piece.global_position)
	if not conversion.get("is_over_board", false):
		return {"is_over_board": false}

	var anchor: Vector2i = conversion["coordinate"]
	var validation_result := PlacementValidator.validate_transformed_placement(
		piece.get_current_local_tile_coordinates(),
		anchor,
		_drop_placement_state.get_occupied_coordinates(),
		_board_view.get_protected_target_coordinates()
	)
	return {
		"is_over_board": true,
		"anchor": anchor,
		"validation_result": validation_result,
	}

func _refresh_board_occupancy() -> void:
	if _board_view == null:
		return
	_board_view.set_occupied_coordinates(_drop_placement_state.get_occupied_coordinates())

func _set_status_text(text: String) -> void:
	var status_label := ui_controls.get_node_or_null("StatusLabel") as Label
	if status_label != null:
		status_label.text = text

func _connect_ui_controls() -> void:
	if reset_layout_button == null:
		return
	if not reset_layout_button.pressed.is_connected(_on_reset_layout_pressed):
		reset_layout_button.pressed.connect(_on_reset_layout_pressed)

func _on_reset_layout_pressed() -> void:
	_reset_layout()

func _reset_layout() -> void:
	_drop_placement_state.clear_all_placements()
	if _piece_tray_controller != null:
		_piece_tray_controller.reset_pieces_to_spawn_positions()
	_refresh_board_occupancy()
	if _board_view != null:
		_board_view.clear_preview()
	_set_status_text("Layout reset")

func _refresh_transform_hints() -> void:
	if _piece_tray_controller == null:
		return

	var can_rotate := false
	var can_flip := false
	for piece_id in _piece_tray_controller.get_piece_ids():
		var piece := _piece_tray_controller.get_piece_by_id(piece_id)
		if piece == null:
			continue
		if piece.get_allowed_rotations().size() > 1:
			can_rotate = true
		if piece.is_flip_allowed():
			can_flip = true
		if can_rotate and can_flip:
			break

	if rotate_hint_label != null:
		rotate_hint_label.text = "Rotate: %s" % ("R" if can_rotate else "N/A")
	if flip_hint_label != null:
		flip_hint_label.text = "Flip: %s" % ("F" if can_flip else "N/A")
