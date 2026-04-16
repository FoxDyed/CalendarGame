extends SceneTree

const BoardModelTest = preload("res://tests/board/board_model_test.gd")
const PieceSetTest = preload("res://tests/pieces/piece_set_test.gd")
const BoardSceneTest = preload("res://tests/board/board_scene_test.gd")
const PieceTransformTest = preload("res://tests/pieces/piece_transform_test.gd")
const DailyTargetSelectorTest = preload("res://tests/targets/daily_target_selector_test.gd")
const FoundationValidatorTest = preload("res://tests/validation/foundation_validator_test.gd")
const MainGameplaySceneTest = preload("res://tests/scenes/main_gameplay_scene_test.gd")

func _initialize() -> void:
	var failures: Array[String] = []

	var board_model_test = BoardModelTest.new()
	if not board_model_test.run_all():
		for failure in board_model_test.failure_messages():
			failures.append("[board] %s" % failure)


	var board_scene_test = BoardSceneTest.new()
	if not board_scene_test.run_all():
		for failure in board_scene_test.failure_messages():
			failures.append("[board_scene] %s" % failure)

	var piece_set_test = PieceSetTest.new()
	if not piece_set_test.run_all():
		for failure in piece_set_test.failure_messages():
			failures.append("[pieces] %s" % failure)

	var piece_transform_test = PieceTransformTest.new()
	if not piece_transform_test.run_all():
		for failure in piece_transform_test.failure_messages():
			failures.append("[piece_transform] %s" % failure)

	var daily_target_selector_test = DailyTargetSelectorTest.new()
	if not daily_target_selector_test.run_all():
		for failure in daily_target_selector_test.failure_messages():
			failures.append("[targets] %s" % failure)

	var foundation_validator_test = FoundationValidatorTest.new()
	if not foundation_validator_test.run_all():
		for failure in foundation_validator_test.failure_messages():
			failures.append("[validation] %s" % failure)

	var main_gameplay_scene_test = MainGameplaySceneTest.new()
	if not main_gameplay_scene_test.run_all():
		for failure in main_gameplay_scene_test.failure_messages():
			failures.append("[scene] %s" % failure)

	if failures.is_empty():
		print("All tests passed.")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)
