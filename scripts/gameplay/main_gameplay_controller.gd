extends Control

const PieceTrayController = preload("res://scripts/gameplay/piece_tray_controller.gd")
const BoardView = preload("res://scripts/board/board_view.gd")

@onready var board: Control = %Board
@onready var piece_tray: Control = %PieceTray
@onready var ui_controls: Control = %UIControls

var _loaded_piece_count := 0
var _board_state: Dictionary = {}
var _board_view: BoardView
var _piece_tray_controller: PieceTrayController

func _ready() -> void:
	# Keep initialization minimal so the scene can boot before puzzle logic exists.
	if board == null or piece_tray == null or ui_controls == null:
		push_error("MainGameplayController is missing required child regions")
		return

	_board_view = board.get_node_or_null("BoardCenter/BoardScene") as BoardView
	_piece_tray_controller = piece_tray.get_node_or_null("TrayContent/PieceTrayScene") as PieceTrayController
	_connect_piece_drag_handlers()

func load_piece_placeholders(piece_definitions: Array[Dictionary]) -> void:
	# Hook for future piece loading flow.
	_loaded_piece_count = piece_definitions.size()
	_set_status_text("Pieces: %d" % _loaded_piece_count)

func update_board_state_placeholder(board_state: Dictionary) -> void:
	# Hook for future board state updates.
	_board_state = board_state.duplicate(true)
	_set_status_text("Board state keys: %d" % _board_state.size())

func _connect_piece_drag_handlers() -> void:
	if _piece_tray_controller == null:
		return

	for piece_id in _piece_tray_controller.get_piece_ids():
		var piece := _piece_tray_controller.get_piece_by_id(piece_id)
		if piece == null:
			continue
		if not piece.drag_moved.is_connected(_on_piece_drag_moved):
			piece.drag_moved.connect(_on_piece_drag_moved)
		if not piece.drag_ended.is_connected(_on_piece_drag_ended):
			piece.drag_ended.connect(_on_piece_drag_ended)

func _on_piece_drag_moved(piece: PieceController) -> void:
	if _board_view == null:
		return

	var conversion := _board_view.try_global_position_to_grid_coordinate(piece.global_position)
	if not conversion.get("is_over_board", false):
		_board_view.clear_preview()
		return

	var anchor: Vector2i = conversion["coordinate"]
	var preview_coordinates := _board_view.transformed_local_tiles_to_board_coordinates(
		piece.get_current_local_tile_coordinates(),
		anchor
	)
	_board_view.set_preview_coordinates(preview_coordinates)

func _on_piece_drag_ended(_piece: PieceController) -> void:
	if _board_view != null:
		_board_view.clear_preview()

func _set_status_text(text: String) -> void:
	var status_label := ui_controls.get_node_or_null("StatusLabel") as Label
	if status_label != null:
		status_label.text = text
