extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DATABASE = preload("res://CardDatabase.gd")

var player_deck = []  # Will be filled from CardDatabase

func _ready() -> void:
	player_deck = CARD_DATABASE.CARDS.keys()
	player_deck.shuffle()

func draw_card():
	if player_deck.size() == 0:
		print("Deck is empty. No more cards to draw.")
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		return null

	var card_drawn_name = player_deck.pop_front()
	print("Drawn card: ", card_drawn_name)

	var card_scene = preload(CARD_SCENE_PATH)
	var card_image_path = "res://assets/Cards/" + card_drawn_name + ".png"
	var new_card = card_scene.instantiate()
	
	# Assign card_id for identification
	new_card.card_id = card_drawn_name
	
	# Set the card image texture
	new_card.get_node("CardImage").texture = load(card_image_path)
	
	# Add card node to CardManager (or wherever cards are managed)
	$"../CardManager".add_child(new_card)
	
	# Add card to player's hand node (if applicable)
	$"../PlayerHand".add_card_to_hand(new_card)
	
	# Return the actual card Node, NOT the name string
	return new_card

func reset_deck():
	player_deck.clear()
	for card_name in CARD_DATABASE.CARDS.keys():
		player_deck.append(card_name)
	player_deck.shuffle()
