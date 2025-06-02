extends Node

# Signal to notify when a skill is used
signal skill_used(skill_name: String)

# References to other nodes
var game_manager: Node
var deck: Node

func _ready():
	game_manager = get_node("../GameManager")
	deck = get_node("../Deck")

# Peek - See one of the dealer's hidden cards
func use_peek() -> void:
	var dealer_hand = game_manager.dealer_hand
	if dealer_hand.size() >= 2:
		# Show the second card (index 1) which is usually hidden
		var card = dealer_hand[1]
		var card_name = card.card_id
		var card_image_path = "res://assets/Cards/" + card_name + ".png"
		card.get_node("CardImage").texture = load(card_image_path)
		print("👁️ Peeked at dealer's hidden card: ", card_name)
	emit_signal("skill_used", "Peek_Icon")

# Swap - Swap last drawn card with a random card from top 3
func use_swap() -> void:
	if game_manager.player_hand.size() > 0:
		var last_card = game_manager.player_hand[-1]
		var top_cards = deck.peek_top_cards(3)
		if top_cards.size() > 0:
			var random_card = top_cards[randi() % top_cards.size()]
			# Remove last card and add new one
			game_manager.player_hand.pop_back()
			game_manager.player_hand.append(random_card)
			print("🔄 Swapped last card with: ", random_card.card_id)
	emit_signal("skill_used", "Swap_Icon")

# Blackjack Boost - If hand is 20, count as 21
func use_blackjack_boost() -> void:
	var hand_value = game_manager.calculate_hand_value(game_manager.player_hand)
	if hand_value == 20:
		print("💪 Blackjack Boost activated! 20 counts as 21!")
		# We'll handle this in the calculate_hand_value function
	emit_signal("skill_used", "Blackjack_Boost_Icon")

# X-Ray - See next card in deck
func use_xray() -> void:
	var next_card = deck.peek_next_card()
	if next_card:
		print("🔍 Next card will be: ", next_card.card_id)
	emit_signal("skill_used", "X_Ray_Icon")

# Guardian Angel - Prevent bust
func use_guardian_angel() -> void:
	print("👼 Guardian Angel activated! You won't bust this turn!")
	# We'll handle this in the test_hand function
	emit_signal("skill_used", "Guardian_Angel_Icon")

# Nullify - Cancel one boss passive effect
func use_nullify() -> void:
	print("❌ Nullify activated! Boss passive effect cancelled!")
	# This will be implemented when boss mechanics are added
	emit_signal("skill_used", "Nullify_Icon")

# Triple Draw - Draw 3 cards and keep one
func use_triple_draw() -> void:
	var drawn_cards = []
	for i in range(3):
		var card = deck.draw_card()
		if card:
			drawn_cards.append(card)
	
	if drawn_cards.size() > 0:
		# For now, we'll just keep the first card
		# TODO: Add UI to let player choose which card to keep
		game_manager.player_hand.append(drawn_cards[0])
		print("🎴 Triple Draw: Kept card: ", drawn_cards[0].card_id)
	emit_signal("skill_used", "Triple_Draw_Icon")
