extends Node



var current_lvl := 1
var current_round := 1
var max_lvl := 9
var is_game_over := false



func _ready():
	print("Game Manager Ready")
	start_lvl()
	
	
func start_lvl():
	print("Starting lvl %d (Round %d)" % [current_lvl, current_round])
	#_Get nodes from Deck and PlayerHand to reset
	var deck = get_node("/root/Main/Deck")
	var hand = get_node("root/Main/PlayerHand")
	deck.reset_deck()
	hand.clear_player_hand()
	#### Update UI, etc.
	
	
#_Call this function if player wins
func player_wins_lvl():
	if current_lvl in [3, 6, 9]:
		current_round += 1
		
	current_lvl += 1
	
	if current_lvl > max_lvl:
		win_game()
	else:
		start_lvl()
		
		
#_Call this function if player loses
func player_loses_lvl():
	is_game_over = true
	print("Game Over! You lost.")
	
	
#_Sends user to state to either go to main menu or restart
func win_game():
	print("Congratulations! You defeated all the bosses.")
