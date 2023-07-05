@tool
extends Control


## Usefull for creating UI control, that behave like a card
##
## It can be any Control node, for example TextureRect
## To control size of this node use Custom Minimum Size property


signal hovered
signal left
signal selected
signal aim(coord : Vector2)
signal apply(coord : Vector2)

## Offset card by this value when hover
@export var hover_offset : Vector2 = Vector2(0, -50)

## Disable card. Disabled card can be hovered but can't be selected and apply
@export var disabled : bool = false :
	get: return disabled
	set(value):
		disabled = value
		_update_disable()

## Modulate color for disabled card
@export var disabled_color : Color = Color.DIM_GRAY : 
	set(value):
		disabled_color = value
		_update_disable()

@export_group("Arrow Line")
@export var line_enabled : bool = true
@export var line_color : Color = Color(Color.WHITE, 0.5)
@export_range(0,10,1) var line_width : int = 5
@export var line_width_curve : Curve

var _hovered : = false
var _selected := false
var _saved_rotation
var _saved_position
var _line2d : Line2D = null
var _tween


func _enter_tree():
	ready.connect(__on_ready)
	minimum_size_changed.connect(update_configuration_warnings)
	mouse_entered.connect(__on_mouse_entered)
	mouse_exited.connect(__on_mouse_exited)

	if Engine.is_editor_hint():
		update_configuration_warnings()



func __on_ready():
	for child in get_children():
		child.mouse_filter = MOUSE_FILTER_IGNORE
	if not Engine.is_editor_hint():
		if line_enabled:
			_line2d = Line2D.new()
#			_line2d.show_behind_parent = true
			_line2d.width = line_width
			_line2d.default_color = line_color
			_line2d.width_curve = line_width_curve
			add_child(_line2d)
#	_update_disable()



func __on_mouse_entered():
	if not _selected:
		# SHOW CONTROL IN FRONT
		z_index += 1
		__on_hovered()
		hovered.emit()
	pass


func __on_mouse_exited():
	if not _selected:
		# RESTORE z_index
		z_index = 0
		__on_left()
		left.emit()
	pass



func __on_hovered():
	_hovered = true
	_saved_rotation = rotation
	_saved_position = position
	rotation = 0
	var new_position = position + hover_offset
	_tween = create_tween()
	_tween.tween_property(self, "position", new_position,0.1)
	pass


func __on_left():
	_hovered = false
	_tween.stop()
	rotation = _saved_rotation
	position = _saved_position
	pass



func _gui_input(event):
	if disabled:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# MOUSE DOWN
		if event.is_pressed() and _hovered:
			_selected = true
			selected.emit()
			if line_enabled:
				_line2d.add_point(size / 2)
				_line2d.add_point(get_local_mouse_position())
		# MOUSE UP
		else:
			_selected = false
			__on_mouse_exited()
			if line_enabled:
				_line2d.clear_points()
			# APPLY ONLY WHEN OUTSIDE CONTROL
			if not Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
				apply.emit(get_global_mouse_position())
	# AIMING
	if event is InputEventMouseMotion:
		if _selected:
			aim.emit(get_global_mouse_position())
			if line_enabled:
				_line2d.remove_point(1)
				_line2d.add_point(get_local_mouse_position())



func _update_disable():
	if disabled:
		modulate = disabled_color
	else:
		modulate = Color.WHITE



func _get_configuration_warnings():
	# BECAUSE CONTAINER NODE CHANGE SIZE OF MOST CHILD
	# WE NEED SET custom_minimum_size TO PREVENT ZERO SIZE
	# OR USE TextureRect AS CARD ROOT NODE
	if custom_minimum_size == Vector2.ZERO:
		return PackedStringArray(["To prevent squashing size to zero, set Custom Minimum Size inside Layout section."])
	else:
		return PackedStringArray([])
