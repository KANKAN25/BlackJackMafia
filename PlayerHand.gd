extends Node2D

const CARD_SCENE_PATH = "res://Card2.tscn"
const CARD_WIDTH = 229
const HAND_Y_POSITION = 840



var player_hand = []
var center_screen_x


func _ready() -> void:
	center_screen_x = get_viewport().size.x/2
	

func add_card_to_hand(card):
	player_hand.insert(0, card)
	update_hand_positions()

func update_hand_positions():
	for i in range(player_hand.size()):
		#get new card position based on the index passed in
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		animate_card_to_position(card, new_position)


func calculate_card_position(index):
	var total_width = (player_hand.size() -1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width /2
	return x_offset


func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
	


func clear_player_hand():
	for card in player_hand:
		card.queue_free()
	player_hand.clear()
