extends Node2D

var player_deck = ["diamond_Alas", "diamond_2"]
const CARD_SCENE_PATH = "res://Scenes/Card.tscn"

var card_database_reference

func _ready() -> void:
	pass
	#print($Area2D.collision_mask)
	player_deck.shuffle()
	card_database_reference = preload("res://CardDatabase.gd")

func draw_card():
	
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	#print("draw card")
	
	#if player drew the last card
	if player_deck.size() ==0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	
	#var card_drawn_name = player_deck[0]
	var card_scene = preload(CARD_SCENE_PATH)
	
	var card_image_path = str("res://assets/diamond_new/" + card_drawn_name + ".png")
	var new_card = card_scene.instantiate()
	new_card.get_node("CardImage").texture = load(card_image_path)

	
	$"../CardManager".add_child(new_card)
	#new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
