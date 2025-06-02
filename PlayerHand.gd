extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_WIDTH = 229
const PLAYER_HAND_Y = 840
const DEALER_HAND_Y = 200

var player_hand = []
var dealer_hand = []
var center_screen_x

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

func add_card_to_hand(card: Node2D, dealer: bool = false) -> void:
	if dealer:
		dealer_hand.append(card)
		update_hand_positions(dealer_hand, DEALER_HAND_Y)
	else:
		player_hand.append(card)
		update_hand_positions(player_hand, PLAYER_HAND_Y)

func update_hand_positions(hand: Array, y_pos: int) -> void:
	var total_cards = hand.size()
	if total_cards == 0:
		return

	var total_width = (total_cards - 1) * CARD_WIDTH
	for i in range(total_cards):
		var x_pos = center_screen_x + i * CARD_WIDTH - total_width / 2
		var new_position = Vector2(x_pos, y_pos)
		var card = hand[i]
		animate_card_to_position(card, new_position)

func animate_card_to_position(card: Node2D, new_position: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)
