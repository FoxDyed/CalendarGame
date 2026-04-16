class_name PieceTrayController
extends Control

const PieceSet = preload("res://model/pieces/piece_set.gd")
const PieceScene = preload("res://scenes/pieces/piece_scene.tscn")

@export var columns: int = 2
@export var horizontal_spacing: float = 168.0
@export var vertical_spacing: float = 152.0
@export var tray_padding: Vector2 = Vector2(16, 16)

@onready var _pieces_layer: Control = %PiecesLayer

var _pieces_by_id: Dictionary = {}
var _spawned_piece_ids: Array[String] = []

func _ready() -> void:
	populate_from_canonical_piece_set()

func populate_from_canonical_piece_set() -> void:
	var pieces_layer := _get_pieces_layer()
	if pieces_layer == null:
		push_error("PieceTrayController is missing PiecesLayer")
		return

	_clear_existing_pieces(pieces_layer)

	var piece_definitions := PieceSet.list_all_pieces()
	for index in piece_definitions.size():
		var piece_data := piece_definitions[index]
		var piece_id := String(piece_data.get("id", ""))
		if piece_id.is_empty() or _pieces_by_id.has(piece_id):
			continue

		var piece := PieceScene.instantiate() as PieceController
		if piece == null:
			continue
		piece.initialize_from_piece_data(piece_data)
		piece.position = _spawn_position_for_index(index)
		pieces_layer.add_child(piece)

		_pieces_by_id[piece_id] = piece
		_spawned_piece_ids.append(piece_id)

func get_piece_count() -> int:
	return _spawned_piece_ids.size()

func get_piece_ids() -> Array[String]:
	return _spawned_piece_ids.duplicate()

func has_piece_id(piece_id: String) -> bool:
	return _pieces_by_id.has(piece_id)

func get_piece_by_id(piece_id: String) -> PieceController:
	return _pieces_by_id.get(piece_id, null)

func _spawn_position_for_index(index: int) -> Vector2:
	var safe_columns := maxi(columns, 1)
	var column := index % safe_columns
	var row := index / safe_columns
	return tray_padding + Vector2(float(column) * horizontal_spacing, float(row) * vertical_spacing)

func _clear_existing_pieces(pieces_layer: Control) -> void:
	for child in pieces_layer.get_children():
		child.queue_free()
	_pieces_by_id.clear()
	_spawned_piece_ids.clear()

func _get_pieces_layer() -> Control:
	if _pieces_layer != null:
		return _pieces_layer
	return get_node_or_null("PiecesLayer") as Control
