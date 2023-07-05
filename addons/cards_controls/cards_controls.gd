@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("CardsContainer", "Container", preload("cards_container.gd"), preload("cards_container.svg"))
	add_custom_type("CardControl", "Control", preload("card_control.gd"), preload("card_control.svg"))
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("CardsContainer")
	remove_custom_type("CardControl")
	pass
