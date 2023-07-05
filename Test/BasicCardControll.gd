extends "res://addons/cards_controls/card_control.gd"


func _ready():
	hovered.connect(_on_hovered)
	left.connect(_on_left)
	apply.connect(_on_apply)



func _on_hovered():
#	hint.show()
	pass


func _on_left():
#	hint.hide()
	pass



func _on_apply(coord):
	disabled = true


