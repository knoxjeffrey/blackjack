=begin 
Blackjack is a card game where you calculate the sum of the values of your cards and try to hit 21, aka "blackjack". Both the player and dealer
are dealt two cards to start the game. All face cards are worth whatever numerical value they show. Suit cards are worth 10. Aces can be worth
either 11 or 1. Example: if you have a Jack and an Ace, then you have hit "blackjack", as it adds up to 21.

After being dealt the initial 2 cards, the player goes first and can choose to either "hit" or "stay". Hitting means deal another card. If the
player's cards sum up to be greater than 21, the player has "busted" and lost. If the sum is 21, then the player wins. If the sum is less than
21, then the player can choose to "hit" or "stay" again. If the player "hits", then repeat above, but if the player stays, then the player's
total value is saved, and the turn moves to the dealer.

By rule, the dealer must hit until she has at least 17. If the dealer busts, then the player wins. If the dealer, hits 21, then the dealer wins.
If, however, the dealer stays, then we compare the sums of the two hands between the player and dealer; higher value wins.

Bonus:
1. Save the player's name, and use it throughout the app.
2. Ask the player if he wants to play again, rather than just exiting.
3. Save not just the card value, but also the suit. 
4. Use multiple decks to prevent against card counting players.
=end

first_deck_of_cards = {hearts: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], diamonds: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], 
                spades: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], clubs: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King']}
                
second_deck_of_cards = {hearts: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], diamonds: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], 
                spades: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], clubs: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King']}
                
third_deck_of_cards = {hearts: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], diamonds: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], 
                spades: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King'], clubs: ['Ace',2,3,4,5,6,7,8,9,'Jack','Queen','King']}

game_deck = [first_deck_of_cards, second_deck_of_cards, third_deck_of_cards]

player_cards = []
dealer_cards = []

def print_string(text)
  puts "==> #{text}"
end

def deal_a_card(from_the_deck)
  deck_chosen_from = from_the_deck.sample
  key_chosen_from_deck = deck_chosen_from.keys.sample
  value_chosen_from_deck = deck_chosen_from[key_chosen_from_deck].sample
  
  remove_from_deck(deck_chosen_from, key_chosen_from_deck, value_chosen_from_deck)
  
  picked_card = { key_chosen_from_deck => value_chosen_from_deck }
end

def remove_from_deck(which_deck, key, value)
  which_deck[key].delete(value)
end

def dealer_and_player_getting_cards(from_the_deck, card_array)
  card_retrieved = deal_a_card(from_the_deck)
  card_array << [card_retrieved.keys[0], card_retrieved.values[0]]
end

def initial_deal(number_of_deals, deck, player_card_array, dealer_card_array)
  dealer_and_player_getting_cards(deck, player_card_array)
  dealer_and_player_getting_cards(deck, dealer_card_array)
  if number_of_deals > 1
    initial_deal(number_of_deals-1, deck, player_card_array, dealer_card_array)
  end
end

print_string("Welcome to this game of Blackjack.  Please enter your name:")

player_name = gets.chomp

initial_deal(2, game_deck, player_cards, dealer_cards)

p player_cards
p dealer_cards             