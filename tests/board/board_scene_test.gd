extends RefCounted

const BoardModel = preload("res://model/board/board_model.gd")
const BoardScene = preload("res://scenes/board/board_scene.tscn")

var _failures: Array[String] = []

func run_all() -> bool:
	test_board_scene_instantiation()
	test_board_renders_all_model_cells()
	test_protected_and_occupied_state_updates()
	test_preview_state_updates_and_clears()
	test_invalid_preview_state_updates()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_board_scene_instantiation() -> void:
	var instance := BoardScene.instantiate()
	_expect(instance != null, "Expected board scene to instantiate")
	if instance == null:
		return

	_expect(instance.get_node_or_null("GridRoot") != null, "Expected GridRoot node")
	instance.queue_free()

func test_board_renders_all_model_cells() -> void:
	var instance := BoardScene.instantiate()
	if instance == null:
		_expect(false, "Expected board scene to instantiate for render count test")
		return

	instance.call("refresh_board")
	_expect(instance.call("get_rendered_cell_count") == BoardModel.get_all_cells().size(), "Expected rendered cell count to match board model cells")
	_expect(instance.get_node("GridRoot").get_child_count() == BoardModel.get_all_cells().size(), "Expected one rendered node per model cell")
	instance.queue_free()

func test_protected_and_occupied_state_updates() -> void:
	var instance := BoardScene.instantiate()
	if instance == null:
		_expect(false, "Expected board scene to instantiate for state update test")
		return

	var protected_coordinate := Vector2i(0, 0)
	var occupied_coordinate := Vector2i(1, 0)

	instance.call("set_protected_target_cells", [protected_coordinate])
	instance.call("set_occupied_coordinates", [occupied_coordinate])

	_expect(instance.call("is_protected_coordinate", protected_coordinate), "Expected protected coordinate lookup to include coordinate")
	_expect(instance.call("get_cell_render_state", protected_coordinate) == "protected", "Expected protected cell to render protected state")
	_expect(instance.call("is_occupied_coordinate", occupied_coordinate), "Expected occupied coordinate lookup to include coordinate")
	_expect(instance.call("get_cell_render_state", occupied_coordinate) == "occupied", "Expected occupied cell to render occupied state")

	instance.call("clear_occupancy")
	_expect(not instance.call("is_occupied_coordinate", occupied_coordinate), "Expected occupancy clear to remove coordinate")
	_expect(instance.call("get_cell_render_state", occupied_coordinate) == "empty", "Expected occupied cell to return to empty state after clear")
	instance.queue_free()

func test_preview_state_updates_and_clears() -> void:
	var instance := BoardScene.instantiate()
	if instance == null:
		_expect(false, "Expected board scene to instantiate for preview test")
		return

	var preview_coordinates: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 2)]
	instance.call("set_preview_coordinates", preview_coordinates)
	_expect(instance.call("get_preview_coordinates") == preview_coordinates, "Expected preview coordinates to be queryable")
	_expect(instance.call("get_cell_render_state", Vector2i(2, 2)) == "preview_valid", "Expected preview cell to render preview state")

	instance.call("clear_preview")
	_expect(instance.call("get_preview_coordinates").is_empty(), "Expected clear_preview to remove preview coordinates")
	_expect(instance.call("get_cell_render_state", Vector2i(2, 2)) == "empty", "Expected preview cell to return to empty when preview clears")
	instance.queue_free()


func test_invalid_preview_state_updates() -> void:
	var instance := BoardScene.instantiate()
	if instance == null:
		_expect(false, "Expected board scene to instantiate for invalid preview test")
		return

	instance.call("set_preview_validation", {
		"valid": false,
		"failure_reason": "out_of_bounds",
		"covered_coordinates": [Vector2i(0, 0), Vector2i(1, 0)],
	})
	_expect(instance.call("get_cell_render_state", Vector2i(0, 0)) == "preview_invalid", "Expected invalid preview cell to render preview_invalid state")
	instance.queue_free()

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
