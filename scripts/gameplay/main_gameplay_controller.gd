extends Control

@onready var board: Control = %Board
@onready var piece_tray: Control = %PieceTray
@onready var ui_controls: Control = %UIControls

var _loaded_piece_count := 0
var _board_state: Dictionary = {}

func _ready() -> void:
	# Keep initialization minimal so the scene can boot before puzzle logic exists.
	if board == null or piece_tray == null or ui_controls == null:
		push_error("MainGameplayController is missing required child regions")

func load_piece_placeholders(piece_definitions: Array[Dictionary]) -> void:
	# Hook for future piece loading flow.
	_loaded_piece_count = piece_definitions.size()
	_set_status_text("Pieces: %d" % _loaded_piece_count)

func update_board_state_placeholder(board_state: Dictionary) -> void:
	# Hook for future board state updates.
	_board_state = board_state.duplicate(true)
	_set_status_text("Board state keys: %d" % _board_state.size())

func _set_status_text(text: String) -> void:
	var status_label := ui_controls.get_node_or_null("StatusLabel") as Label
	if status_label != null:
		status_label.text = text
