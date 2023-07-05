extends Label




func _on_card_hovered():
	text = "HOVERED"


func _on_card_left():
	text = "LEFT"


func _on_card_selected():
	text = "SELECTED"


func _on_card_apply(coord):
	text = "APPLY on %s" % coord


func _on_card_aim(coord):
	text = "AIM on %s" % coord
