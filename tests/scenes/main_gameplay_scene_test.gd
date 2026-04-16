extends RefCounted

const GameplayScene = preload("res://scenes/gameplay/main_gameplay_scene.tscn")

var _failures: Array[String] = []

func run_all() -> bool:
	test_scene_instantiates_with_required_regions()
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
	_expect(instance.get_node_or_null("RootMargin/MainLayout/PlayArea/PieceTray/TrayContent/PieceTrayScene") != null, "Expected PieceTray scene to be integrated into gameplay scene")
	instance.queue_free()

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
