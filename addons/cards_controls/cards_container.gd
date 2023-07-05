@tool
extends Container

## Card Container
## Used for sort and position children (CardControls)

enum TYPE {LINE, ARC}

signal sorted

@export var sorting_type : TYPE = 0:
	get: return sorting_type
	set(value):
		sorting_type = value
		queue_sort()

@export_group("Arc")

## Curvature for arc
@export_range(0.0,1000.0,1.0) var arc_radius : float = 600.0 :
	get: return arc_radius
	set(value):
		arc_radius = value
		queue_sort()

## Width for arc
@export_range(0.0,1000.0,1.0) var arc_width : float = 600.0 :
	get: return arc_width
	set(value):
		arc_width = value
		queue_sort()

## Max angle beetwen first and last child
@export_range(0.0, 90.0, 1.0) var arc_fill : float = 40.0:
	get: return arc_fill
	set(value):
		arc_fill = value
		queue_sort()

## Maximum distance beetwen children
@export_range(0.0, 90.0, 1.0) var arc_max_distance_beetwen_card : float = 10.0:
	get: return arc_max_distance_beetwen_card
	set(value):
		arc_max_distance_beetwen_card = value
		queue_sort()

@export_group("Line")

## If enabled, children can't be wider than max_width.
@export var limit_max_width : bool = false:
	get: return limit_max_width
	set(value):
		limit_max_width = value
		queue_sort()

## The maximum width that children can occupy if limit_max_width enabled
@export_range(0, 10000, 1) var max_width : int = 600:
	get: return max_width
	set(value):
		max_width = value
		queue_sort()


## Separation between children. Not affected if limit_width enabled.
@export var separation : int = 0 :
	get: return separation
	set(value):
		separation = value
		queue_sort()




func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		for child in get_children():
			sort()



func remove_children():
	for child in get_children():
		remove_child(child)
		child.queue_free()


func sort():
	match sorting_type:
		TYPE.LINE: _sort_as_line()
		TYPE.ARC: _sort_as_arc()
	queue_redraw()
	pass



func _sort_as_line():
	var children = get_children()
	var middle = size / 2
	var total_children_width = 0
	for child in children:
		total_children_width += child.size.x
	var total_width_with_separation = total_children_width + (get_child_count() -1) * separation
	var result_width = total_width_with_separation
	var result_separation = separation
	if limit_max_width:
		if total_width_with_separation > max_width:
			var oversize = total_width_with_separation - max_width
			result_separation = separation - (oversize / (get_child_count() -1))
			result_width = max_width
	var x = middle.x - result_width / 2
	for child in get_children():
		child.rotation_degrees = 0
		child.position.x = x
		child.position.y = 0
		x += child.size.x + result_separation
	sorted.emit()




func _sort_as_arc():
	var uniform_distribution_start_degree  = 270.0 - float((get_child_count() - 1)) * arc_max_distance_beetwen_card /2
	var limited_distribution_start_degree  = 270.0 - arc_fill / 2.0
	var start_degrees = max(uniform_distribution_start_degree, limited_distribution_start_degree)
	var offset = (270 - start_degrees) * 2 / (get_child_count() - 1)
	offset = max(0, offset)
	var degrees = start_degrees
#	var start_pos = _get_arc_position(start_degrees - offset)
#	var prev_pos = start_pos
	for child in get_children():
		child.pivot_offset = Vector2(child.size.x/2, child.size.y/2)
		var x = _get_arc_position(degrees).x - child.size.x /2
		var y = _get_arc_position(degrees).y
#		child.position = Vector2(x, y)
		await create_tween().tween_property(child, "position", Vector2(x,y), 0.2).set_ease(Tween.EASE_OUT)
		var prev_pos = _get_arc_position(degrees - offset)
		var next_pos = _get_arc_position(degrees + offset)
		var rot = (next_pos - prev_pos).angle()
		child.rotation_degrees = rad_to_deg(rot)# + 5
		degrees += offset
	sorted.emit()
	pass



func _get_arc_position(degrees) -> Vector2:
#	var a = size.x / 2
	var a = arc_width / 2
	var b = arc_radius / 2
	degrees = deg_to_rad(degrees)
	var x = a*(cos(degrees))  + size.x / 2
	var y = b*(sin(degrees))  + b
	return Vector2(x,y)




func _draw():
	if Engine.is_editor_hint():
		if sorting_type == TYPE.LINE and limit_max_width:
			var rect = Rect2(size.x/2 - max_width /2, 0, max_width, size.y)
			draw_rect(rect, Color.GREEN_YELLOW,false,1.0)
		elif sorting_type == TYPE.ARC:
#			draw_arc(Vector2(size.x/2, size.y/2 + arc_radius), arc_radius, deg_to_rad(230), deg_to_rad(310), 20, Color.GREEN_YELLOW,1.0)
			var start_point = _get_arc_position(200)
			var prev_point = start_point
			for deg in range(200,350,10):
				var next_point = _get_arc_position(deg)
				draw_line(prev_point, next_point, Color.GREEN_YELLOW, 1.0)
				prev_point = next_point





