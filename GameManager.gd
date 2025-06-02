extends Node

const CardDatabase = preload("res://CardDatabase.gd")
const CARD_BACK_TEXTURE = preload("res://assets/Cards/Backside_Card.png")

var player_hand: Array = []
var dealer_hand: Array = []

var is_player_turn: bool = true
var is_player_busted: bool = false

func _ready():
	print("✅ GameManager ready!")
	reset_game()

func reset_game():
	player_hand.clear()
	dealer_hand.clear()
	is_player_turn = true
	is_player_busted = false
	print("🔁 Game reset. Player's turn starts.")

	# Deal 2 cards to player at start
	var deck = get_node("../Deck")
	for i in range(2):
		var card = deck.draw_card()
		if card:
			add_card_to_hand(card)
	# add 2 cards for dealer

func calculate_hand_value(hand: Array) -> int:
	var total = 0
	var ace_count = 0

	for card in hand:
		var card_name = card.card_id

		if not CardDatabase.CARDS.has(card_name):
			print("⚠️ Warning: Card name not found in database: ", card_name)
			continue

		var card_data = CardDatabase.CARDS[card_name]
		var value = card_data.get("value", 0)
		total += value

		if value == 1 and card_data.has("alt_value"):
			ace_count += 1

	while ace_count > 0 and total + 10 <= 21:
		total += 10
		ace_count -= 1

	return total

func test_hand():
	var hand_total = calculate_hand_value(player_hand)
	print("🧮 Player hand total: ", hand_total)

	if hand_total > 21:
		print("💥 Bust! Player can't draw more.")
		is_player_busted = true
		is_player_turn = false
		dealer_turn()
	elif hand_total == 21:
		print("🎉 Blackjack! Turn ends.")
		is_player_turn = false
		dealer_turn()
	else:
		print("🃏 Player can continue drawing.")

func add_card_to_hand(card: Node):
	player_hand.append(card)
	test_hand()

func add_card_to_dealer(card: Node):
	dealer_hand.append(card)

func _on_HitButton_pressed():
	if is_player_turn and not is_player_busted:
		var deck = get_node("../Deck")
		var new_card = deck.draw_card()
		if new_card:
			add_card_to_hand(new_card)

func _on_StandButton_pressed():
	if is_player_turn:
		print("Stand button pressed")
		is_player_turn = false
		dealer_turn()

func dealer_turn():
	print("🂠 Dealer's turn starts.")
	# wala pa anything here

func decide_winner():
	var player_total = calculate_hand_value(player_hand)
	var dealer_total = calculate_hand_value(dealer_hand)

	print("📊 Final Results — Player: ", player_total, " | Dealer: ", dealer_total)

	if player_total > 21:
		print("❌ Player busts. Dealer wins.")
	elif dealer_total > 21:
		print("❌ Dealer busts. Player wins!")
	elif player_total > dealer_total:
		print("✅ Player wins!")
	elif dealer_total > player_total:
		print("🏆 Dealer wins!")
	else:
		print("🤝 It's a tie!")

	# Optionally: Auto reset or wait for user input
	# reset_game()  # Uncomment to restart immediately
