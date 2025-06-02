extends Node2D

const CARD_SCENE_PATH = "res://Scenes/Card.tscn"
const CARD_DATABASE = preload("res://CardDatabase.gd")

var player_deck = []  # Will be filled from CardDatabase

var card_database_reference

func _ready() -> void:
	#print($Area2D.collision_mask)
	player_deck = CARD_DATABASE.CARDS.keys()
	player_deck.shuffle()
	

func draw_card():
	
	var card_drawn_name = player_deck.pop_front()
	print(card_drawn_name)
	#print("draw card")
	
	#if player drew the last card
	if player_deck.size() ==0:
		print("Deck is empty. No more cards to draw.")
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		return
	#var card_drawn_name = player_deck[0]
	var card_scene = preload(CARD_SCENE_PATH)
	
	var card_image_path = str("res://assets/Cards/" + card_drawn_name + ".png")
	var new_card = card_scene.instantiate()
	new_card.get_node("CardImage").texture = load(card_image_path)

	
	$"../CardManager".add_child(new_card)
	#new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
