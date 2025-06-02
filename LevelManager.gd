extends Node

func set_character_sprite(sprite_node: Sprite2D, texture_path: String) -> void:
	var new_texture = load(texture_path)
	if new_texture:
		sprite_node.texture = new_texture
	else:
		print("⚠️ Could not load texture at: ", texture_path)

func initialize_level(level: int):
	var dealer_sprite = get_node("../Dealer/Dealer")
	var player_sprite = get_node("../PlayerCard/Player")

	var dealer_path = "res://assets/Dealers/Lvl" + str(level) + "_Dealer.png"
	var player_path = "res://assets/PlayerCards/Player_Card_Lvl_" + str(level) + ".png"

	set_character_sprite(dealer_sprite, dealer_path)
	set_character_sprite(player_sprite, player_path)

func end_game(player_win, tie):
	var game_result_sprite = get_node("../Turns/ResultDisplay")
	var game_result_path
	if player_win == true:
		game_result_path = "res://assets/Quit_Window/YOU_WIN.png"
	elif tie == true:
		game_result_path = "res://assets/Quit_Window/YOU_WIN.png"
	else:
		game_result_path = "res://assets/Quit_Window/YOU_LOST.png"
	set_character_sprite(game_result_sprite, game_result_path)
	game_result_sprite.visible = true
		
