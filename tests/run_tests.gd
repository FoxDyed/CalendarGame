extends SceneTree

const BoardModelTest = preload("res://tests/board/board_model_test.gd")

func _initialize() -> void:
	var test_runner = BoardModelTest.new()
	var passed := test_runner.run_all()

	if passed:
		print("All board model tests passed.")
		quit(0)
		return

	for failure in test_runner.failure_messages():
		push_error(failure)
	quit(1)
