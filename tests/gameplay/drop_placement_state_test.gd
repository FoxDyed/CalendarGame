extends RefCounted

const DropPlacementState = preload("res://model/gameplay/drop_placement_state.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_commit_valid_placement_updates_occupancy()
	test_invalid_drop_restores_original_position_and_state()
	test_repositioning_placed_piece_clears_old_occupancy_during_drag()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_commit_valid_placement_updates_occupancy() -> void:
	var state := DropPlacementState.new()
	state.begin_drag("L5", Vector2(120, 120))
	state.commit_drop("L5", Vector2i(1, 1), [Vector2i(1, 1), Vector2i(1, 2)], Vector2(400, 300))

	_expect(state.has_piece_placement("L5"), "Expected piece to be placed after commit")
	_expect(state.get_occupied_coordinates() == [Vector2i(1, 1), Vector2i(1, 2)], "Expected occupied cells to match committed coordinates")

func test_invalid_drop_restores_original_position_and_state() -> void:
	var state := DropPlacementState.new()
	state.begin_drag("P5", Vector2(40, 50))
	var rejection := state.reject_drop("P5", Vector2(900, 900))

	_expect(not state.has_piece_placement("P5"), "Expected unplaced piece to remain unplaced after rejection")
	_expect(rejection.get("restore_global_position") == Vector2(40, 50), "Expected rejected drop to restore original free position")

func test_repositioning_placed_piece_clears_old_occupancy_during_drag() -> void:
	var state := DropPlacementState.new()
	state.begin_drag("T5", Vector2(30, 40))
	state.commit_drop("T5", Vector2i(3, 3), [Vector2i(3, 3), Vector2i(4, 3)], Vector2(200, 200))

	state.begin_drag("T5", Vector2(200, 200))
	_expect(state.get_occupied_coordinates().is_empty(), "Expected prior occupied cells to clear while placed piece is being dragged")

	var rejection := state.reject_drop("T5", Vector2(700, 700))
	_expect(rejection.get("restore_global_position") == Vector2(200, 200), "Expected invalid re-drop to return piece to previous placed position")
	_expect(state.get_occupied_coordinates() == [Vector2i(3, 3), Vector2i(4, 3)], "Expected previous occupied cells to restore after invalid re-drop")

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
