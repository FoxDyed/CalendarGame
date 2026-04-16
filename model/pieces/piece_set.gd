class_name PieceSet
extends RefCounted

## Local offset convention:
## - Every tile offset is a Vector2i(x, y) measured from the piece's local origin.
## - normalize_tiles() shifts offsets so the minimum x/y becomes (0, 0).
## - Normalized tiles are sorted deterministically by y first, then x.

const _CANONICAL_PIECES := [
	{
		"id": "L5",
		"tiles": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 3)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": true},
		"display": {"name": "Long L", "color": "#B87333", "style": "oak"},
	},
	{
		"id": "P5",
		"tiles": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": true},
		"display": {"name": "Penta P", "color": "#7B3F00", "style": "walnut"},
	},
	{
		"id": "T5",
		"tiles": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": false},
		"display": {"name": "Penta T", "color": "#A67B5B", "style": "maple"},
	},
	{
		"id": "U5",
		"tiles": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": false},
		"display": {"name": "Penta U", "color": "#9C6B30", "style": "oak"},
	},
	{
		"id": "V5",
		"tiles": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": false},
		"display": {"name": "Penta V", "color": "#6F4E37", "style": "walnut"},
	},
	{
		"id": "Z6",
		"tiles": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2), Vector2i(3, 2)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": true},
		"display": {"name": "Hexa Z", "color": "#8B5A2B", "style": "maple"},
	},
	{
		"id": "L8",
		"tiles": [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4), Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": true},
		"display": {"name": "Octa Long L", "color": "#C68642", "style": "oak"},
	},
	{
		"id": "P8",
		"tiles": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(0, 3), Vector2i(1, 3)],
		"transform": {"allowed_rotations": [0, 90, 180, 270], "allow_mirror": false},
		"display": {"name": "Octa Block", "color": "#D2B48C", "style": "maple"},
	},
]

static var _pieces_cache: Array[Dictionary]

static func list_all_pieces() -> Array[Dictionary]:
	_ensure_cache()
	return _pieces_cache.duplicate(true)

static func count_tiles(piece: Dictionary) -> int:
	if not piece.has("tiles"):
		return 0
	return (piece["tiles"] as Array).size()

static func has_duplicate_local_offsets(piece: Dictionary) -> bool:
	if not piece.has("tiles"):
		return false

	var seen := {}
	for tile in piece["tiles"]:
		if seen.has(tile):
			return true
		seen[tile] = true
	return false

static func normalize_tiles(tile_offsets: Array[Vector2i]) -> Array[Vector2i]:
	if tile_offsets.is_empty():
		return []

	var min_x := tile_offsets[0].x
	var min_y := tile_offsets[0].y
	for tile in tile_offsets:
		if tile.x < min_x:
			min_x = tile.x
		if tile.y < min_y:
			min_y = tile.y

	var normalized: Array[Vector2i] = []
	for tile in tile_offsets:
		normalized.append(Vector2i(tile.x - min_x, tile.y - min_y))

	normalized.sort_custom(Callable(PieceSet, "_sort_tiles"))
	return normalized

static func _ensure_cache() -> void:
	if _pieces_cache != null:
		return

	_pieces_cache = []
	for piece in _CANONICAL_PIECES:
		var normalized_piece := (piece as Dictionary).duplicate(true)
		normalized_piece["tiles"] = normalize_tiles(normalized_piece["tiles"])
		_pieces_cache.append(normalized_piece)

static func _sort_tiles(a: Vector2i, b: Vector2i) -> bool:
	if a.y == b.y:
		return a.x < b.x
	return a.y < b.y
