class_name DropPlacementState
extends RefCounted

var _placements_by_piece_id: Dictionary = {}
var _drag_snapshots_by_piece_id: Dictionary = {}

func begin_drag(piece_id: String, current_global_position: Vector2) -> void:
	var snapshot := {
		"global_position": current_global_position,
		"had_placement": false,
	}

	if _placements_by_piece_id.has(piece_id):
		snapshot["had_placement"] = true
		snapshot["placement"] = (_placements_by_piece_id[piece_id] as Dictionary).duplicate(true)
		_placements_by_piece_id.erase(piece_id)

	_drag_snapshots_by_piece_id[piece_id] = snapshot

func commit_drop(piece_id: String, anchor: Vector2i, covered_coordinates: Array[Vector2i], snapped_global_position: Vector2) -> void:
	_placements_by_piece_id[piece_id] = {
		"anchor": anchor,
		"covered_coordinates": covered_coordinates.duplicate(),
		"global_position": snapped_global_position,
	}
	_drag_snapshots_by_piece_id.erase(piece_id)

func reject_drop(piece_id: String, fallback_global_position: Vector2) -> Dictionary:
	var snapshot: Dictionary = _drag_snapshots_by_piece_id.get(piece_id, {})
	_drag_snapshots_by_piece_id.erase(piece_id)

	if snapshot.is_empty():
		return {
			"restore_global_position": fallback_global_position,
			"restored_previous_placement": false,
		}

	if bool(snapshot.get("had_placement", false)):
		var placement := (snapshot.get("placement", {}) as Dictionary).duplicate(true)
		if not placement.is_empty():
			_placements_by_piece_id[piece_id] = placement
		return {
			"restore_global_position": snapshot.get("global_position", fallback_global_position),
			"restored_previous_placement": true,
		}

	return {
		"restore_global_position": snapshot.get("global_position", fallback_global_position),
		"restored_previous_placement": false,
	}

func get_occupied_coordinates() -> Array[Vector2i]:
	var unique := {}
	for placement in _placements_by_piece_id.values():
		var placement_dict := placement as Dictionary
		for coordinate in placement_dict.get("covered_coordinates", []):
			if coordinate is Vector2i:
				unique[coordinate] = true

	var occupied: Array[Vector2i] = []
	for coordinate in unique.keys():
		occupied.append(coordinate)
	occupied.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y
	)
	return occupied

func has_piece_placement(piece_id: String) -> bool:
	return _placements_by_piece_id.has(piece_id)

func get_piece_placement(piece_id: String) -> Dictionary:
	if not _placements_by_piece_id.has(piece_id):
		return {}
	return (_placements_by_piece_id[piece_id] as Dictionary).duplicate(true)

func has_active_drag_snapshot(piece_id: String) -> bool:
	return _drag_snapshots_by_piece_id.has(piece_id)

func clear_all_placements() -> void:
	_placements_by_piece_id.clear()
	_drag_snapshots_by_piece_id.clear()
