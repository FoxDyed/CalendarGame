class_name BoardDropTargeting
extends RefCounted

static func local_position_to_grid_coordinate(local_position: Vector2, cell_size: Vector2, cell_gap: Vector2, grid_width: int, grid_height: int) -> Dictionary:
	var step := cell_size + cell_gap
	if step.x <= 0.0 or step.y <= 0.0:
		return {"is_over_board": false}

	if local_position.x < 0.0 or local_position.y < 0.0:
		return {"is_over_board": false}

	var grid_coordinate := Vector2i(
		int(floor(local_position.x / step.x)),
		int(floor(local_position.y / step.y))
	)

	if grid_coordinate.x < 0 or grid_coordinate.x >= grid_width:
		return {"is_over_board": false}
	if grid_coordinate.y < 0 or grid_coordinate.y >= grid_height:
		return {"is_over_board": false}

	return {
		"is_over_board": true,
		"coordinate": grid_coordinate,
	}

static func transformed_tiles_to_board_coordinates(local_tiles: Array[Vector2i], anchor: Vector2i) -> Array[Vector2i]:
	var board_coordinates: Array[Vector2i] = []
	for tile in local_tiles:
		board_coordinates.append(anchor + tile)
	return board_coordinates
