extends Node2D

#func _on_skills_btn_pressed():
#	$Skills.visible = true

func _on_skills_btn_pressed():
	var game_manager = get_node("GameManager")
	if game_manager:
		game_manager._on_skills_button_pressed()
