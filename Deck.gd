extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DATABASE = preload("res://CardDatabase.gd")

var player_deck = []  # Will be filled from CardDatabase
var card_sound_player: AudioStreamPlayer

func _ready() -> void:
	player_deck = CARD_DATABASE.CARDS.keys()
	player_deck.shuffle()
	
	# Setup audio player for card sounds
	card_sound_player = AudioStreamPlayer.new()
	card_sound_player.stream = load("res://assets/music/cue_card_set_down.mp3")
	add_child(card_sound_player)

func draw_card(dealer=false, hide_card=false):
	if player_deck.size() == 0:
		print("Deck is empty. No more cards to draw.")
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		return null

	var card_drawn_name = player_deck.pop_front()
	print("Drawn card: ", card_drawn_name)

	var card_scene = preload(CARD_SCENE_PATH)
	var card_image_path = "res://assets/Cards/" + card_drawn_name + ".png"
	if hide_card:
		card_image_path = "res://assets/Cards/Backside_Card.png"
	var new_card = card_scene.instantiate()
	
	# Assign card_id for identification
	new_card.card_id = card_drawn_name
	
	# Set the card image texture
	new_card.get_node("CardImage").texture = load(card_image_path)
	
	# Add card node to CardManager (or wherever cards are managed)
	$"../CardManager".add_child(new_card)
	
	# Add card to player's hand node (if applicable)
	$"../PlayerHand".add_card_to_hand(new_card, dealer)
	
	# Play card set down sound
	card_sound_player.play()
	
	# Return the actual card Node, NOT the name string
	return new_card

func reset_deck():
	player_deck.clear()
	for card_name in CARD_DATABASE.CARDS.keys():
		player_deck.append(card_name)
	player_deck.shuffle()

# Peek at the next card without drawing it
func peek_next_card() -> Node:
	if player_deck.size() > 0:
		var card_id = player_deck[0]
		var card_scene = preload(CARD_SCENE_PATH)
		var card = card_scene.instantiate()
		card.card_id = card_id
		return card
	return null

# Peek at top N cards (for swap)
func peek_top_cards(count: int) -> Array:
	var cards = []
	for i in range(min(count, player_deck.size())):
		var card_id = player_deck[i]
		var card_scene = preload(CARD_SCENE_PATH)
		var card = card_scene.instantiate()
		card.card_id = card_id
		cards.append(card)
	return cards
