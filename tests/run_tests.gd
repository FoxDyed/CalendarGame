extends SceneTree

const BoardModelTest = preload("res://tests/board/board_model_test.gd")
const PieceSetTest = preload("res://tests/pieces/piece_set_test.gd")
const PieceTransformTest = preload("res://tests/pieces/piece_transform_test.gd")

func _initialize() -> void:
	var failures: Array[String] = []

	var board_model_test = BoardModelTest.new()
	if not board_model_test.run_all():
		for failure in board_model_test.failure_messages():
			failures.append("[board] %s" % failure)

	var piece_set_test = PieceSetTest.new()
	if not piece_set_test.run_all():
		for failure in piece_set_test.failure_messages():
			failures.append("[pieces] %s" % failure)

	var piece_transform_test = PieceTransformTest.new()
	if not piece_transform_test.run_all():
		for failure in piece_transform_test.failure_messages():
			failures.append("[piece_transform] %s" % failure)

	if failures.is_empty():
		print("All tests passed.")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)
