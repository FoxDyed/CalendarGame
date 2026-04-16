extends RefCounted

const GameplayScene = preload("res://scenes/gameplay/main_gameplay_scene.tscn")
const DailyTargetSelector = preload("res://model/targets/daily_target_selector.gd")
const PieceSet = preload("res://model/pieces/piece_set.gd")

var _failures: Array[String] = []

func run_all() -> bool:
	test_scene_instantiates_with_required_regions()
	test_scene_initializes_single_fixed_daily_puzzle_state()
	return _failures.is_empty()

func failure_messages() -> Array[String]:
	return _failures.duplicate()

func test_scene_instantiates_with_required_regions() -> void:
	var instance := GameplayScene.instantiate()
	_expect(instance != null, "Expected gameplay scene to instantiate")
	if instance == null:
		return

	_expect(instance.get_node_or_null("RootMargin/MainLayout/PlayArea/Board") != null, "Expected Board placeholder node")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/PlayArea/PieceTray") != null, "Expected PieceTray placeholder node")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/UIControls") != null, "Expected UIControls placeholder node")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/UIControls/UIRow/RotateHintLabel") != null, "Expected rotate hint control to exist")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/UIControls/UIRow/FlipHintLabel") != null, "Expected flip hint control to exist")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/UIControls/UIRow/ResetLayoutButton") != null, "Expected reset layout button to exist")
	_expect(instance.get_node_or_null("RootMargin/MainLayout/PlayArea/PieceTray/TrayContent/PieceTrayScene") != null, "Expected PieceTray scene to be integrated into gameplay scene")
	instance.queue_free()

func test_scene_initializes_single_fixed_daily_puzzle_state() -> void:
	var instance := GameplayScene.instantiate()
	_expect(instance != null, "Expected gameplay scene to instantiate for daily puzzle integration checks")
	if instance == null:
		return

	instance._ready()

	var fixed_date: Dictionary = instance.get_fixed_test_date()
	_expect(fixed_date == {"year": 2026, "month": 1, "day": 15}, "Expected fixed deterministic test date for integrated gameplay scene")

	var expected_targets := DailyTargetSelector.get_target_coordinates_for_date_parts(
		fixed_date["year"],
		fixed_date["month"],
		fixed_date["day"]
	)
	var board_scene := instance.get_node_or_null("RootMargin/MainLayout/PlayArea/Board/BoardCenter/BoardScene")
	_expect(board_scene != null, "Expected integrated board scene to exist for daily target checks")
	if board_scene != null:
		_expect(board_scene.get_protected_target_coordinates() == expected_targets, "Expected board to initialize protected target coordinates from daily target selector")

	var piece_tray_scene := instance.get_node_or_null("RootMargin/MainLayout/PlayArea/PieceTray/TrayContent/PieceTrayScene")
	_expect(piece_tray_scene != null, "Expected integrated piece tray scene to exist for canonical tray checks")
	if piece_tray_scene != null:
		_expect(piece_tray_scene.get_piece_count() == PieceSet.list_all_pieces().size(), "Expected piece tray to be populated with canonical piece set")

	instance.queue_free()

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
