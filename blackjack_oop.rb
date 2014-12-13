require 'pry'

module TextFormat
  def self.print_string(text)
    puts "\n*** #{text} ***"
  end
  
  def self.chomp_it
    gets.chomp
  end
  
  def self.entered_correct_choice?(the_decision)
    if ['y', 'n'].include?(the_decision.downcase)
      true
    else
      print_string "You must enter Y or N. Please try again"
    end
  end

end

module MoneyChecker
  def self.print_string(text)
    puts "\n*** #{text} ***"
  end
  
  def self.correct_money_entered?(the_bet_value, bank_account)
    if the_bet_value =~ /\D/
      print_string "You must enter a valid number"
    elsif the_bet_value.to_i == 0
      print_string "You must enter a value higher than zero"
    elsif (bank_account - the_bet_value.to_i) < 0 
      print_string "You do not have enough funds for that bet. Please enter a new bet"
    else
      true
    end
  end
end

module HandTotal
  
  #returns a value with the hand total in it. 
  def self.card_total(cards_held_array)
    value_array = cards_held_array.map { |v| v[1] }
    card_value_counter = 0
  
    value_array.each do |value|
      if value.is_a? Integer
        card_value_counter += value
      elsif value != 'A'
        card_value_counter += 10
      else
        card_value_counter += 11
      end
    end
  
    #decided total based on total number of aces. Will keep adjusting ace value to 1 until the toal is 21 or under
    value_array.select { |v| v == 'A'}.count.times do
      card_value_counter -= 10 if card_value_counter > 21
    end
  
    card_value_counter
  end
end

class Cards
  attr_reader :suits, :values
  def initialize
    @suits = ["\e[31m♥\e[0m", "\e[31m♦\e[0m", '♠', '♣']
    @values = ['A',2,3,4,5,6,7,8,9,'J','Q','K']
  end  
end

class Deck
  attr_reader :deck
  
  def initialize
    @deck = []
    @suits_and_values = Cards.new
    @card = @suits_and_values.suits.each do |suit|
      @suits_and_values.values.each do |value|
        @deck << [suit, value]
      end
    end
  end
end

class DeckHandler
  attr_accessor :game_deck
  def initialize
    @game_deck = []
  end
  
  def replenish_deck(number_of_decks)
    self.game_deck = []
    number_of_decks.times { game_deck << Deck.new.deck }
    game_deck.flatten!(1).shuffle!
  end
  
  def deal_card
    game_deck.pop
  end
  
  def display_cards(card_array)
    card_images = [[],[],[],[],[]]
    card_array.each do |card|
      card_images.each_index { |index| card_images[index] << make_card_image(card)[index] }
    end
    
    card_images.each do |person|
      puts person.join(" ")
    end
  end
  
  def unturned_card
    ['*','*']
  end
  
  private
  
  def make_card_image(card_array)
    array = []
    
    array << "┌─────┐"
    array << "│#{card_array[1]}    │"
    array << "│  #{card_array[0]}  │"
    array << "│    #{card_array[1]}│"
    array << "└─────┘"
    
    array
  end
end


class Bank
  attr_accessor :bank
  
  def initialize(how_much_in_account)
    @bank = how_much_in_account
  end
  
  def deposit_money(amount)
    self.bank += amount
  end
  
  def withdraw_money(amount)
    self.bank -= amount
  end
end

class Dealer
  attr_reader :name
  attr_accessor :cards_held
  
  def initialize(name)
    @name = name
    @cards_held = []
  end
  
  def is_dealer_sticking?(dealer_total)
    if dealer_total.between?(18,21)
      return true
    end
  end
  
  def clear_hand
    self.cards_held = []
  end
end

class Player
  attr_reader :name
  attr_accessor :cards_held
  
  def initialize(name, amount_in_bank)
    @name = name
    @@account = Bank.new(amount_in_bank)
    @cards_held = []
  end
  
  def clear_hand
    self.cards_held = []
  end
  
  def amount_in_account
    @@account.bank
  end
  
  def win_money(amount)
    @@account.deposit_money(amount)
  end
  
  def lose_money(amount)
    @@account.withdraw_money(amount)
  end
end

class GameFlow
  include TextFormat
  include MoneyChecker
  include HandTotal
  
  NUMBER_OF_DECKS_FOR_GAME = 3
  
  attr_reader :player, :dealer
  attr_accessor :blackjack_deck, :total_cards_played
  
  def initialize
    puts `clear`
    TextFormat.print_string "Welcome to this game of Blackjack.  Please enter your name:"
    player_name = TextFormat.chomp_it
    
    @player = Player.new(player_name,100)
    @dealer = Dealer.new('Kryton')
    @blackjack_deck = DeckHandler.new
    @total_cards_played = 0
  end
  
  def show_cards_on_table(dealer_cards_held, player_cards_held)
    TextFormat.print_string "The dealers cards are:"
    blackjack_deck.display_cards(dealer_cards_held)
  
    TextFormat.print_string "#{player.name}'s cards are:"
    blackjack_deck.display_cards(player_cards_held)
  end
  
  def declare_result(bet_placed)
    if HandTotal.card_total(player.cards_held) > HandTotal.card_total(dealer.cards_held)
      player.win_money(bet_placed)
      TextFormat.print_string "Congratulations #{name}, you have won the game!"
    elsif HandTotal.card_total(player.cards_held) < HandTotal.card_total(dealer.cards_held)
      player.lose_money(bet_placed)
      TextFormat.print_string "Sorry #{player.name}, the dealer has won the game."
    else
      TextFormat.print_string "It's a tie! Have a go at beating the dealer again #{player.name}."
    end
  end
  
  def game_sequence
    TextFormat.print_string "#{player.name} you have £#{player.amount_in_account} in your account. Let's play!"
  
    puts `clear`
    if (total_cards_played > (NUMBER_OF_DECKS_FOR_GAME*40)) || (total_cards_played == 0)
      blackjack_deck.replenish_deck(NUMBER_OF_DECKS_FOR_GAME)
      total_cards_played = 0
=begin
      TextFormat.print_string "Getting the deck ready..."
      sleep 1
      TextFormat.print_string "Ready to play!"
      sleep 1
=end
    end
  
    puts `clear`
    player.clear_hand
    dealer.clear_hand
    begin
      TextFormat.print_string "Place your bet! You have £#{player.amount_in_account} in your account"
      bet_placed = gets.chomp
    end while !MoneyChecker.correct_money_entered?(bet_placed, player.amount_in_account)
  
    puts `clear`
  
    2.times { player.cards_held << blackjack_deck.deal_card }
    2.times { dealer.cards_held << blackjack_deck.deal_card }
  
    dealer_hand_with_hole_card = [blackjack_deck.unturned_card, dealer.cards_held[0]]
    show_cards_on_table(dealer_hand_with_hole_card, player.cards_held)
  
    if HandTotal.card_total(player.cards_held) == 21
      TextFormat.print_string "Well done #{player.name}, you have won the game!"
      player.win_money(bet_placed.to_i)
      return
    end
  
    puts `clear`
  
    begin
      show_cards_on_table(dealer_hand_with_hole_card, player.cards_held)
      break if HandTotal.card_total(player.cards_held) > 21
    
      begin
        TextFormat.print_string "#{player.name}, would you like another card? Y or N"
        decision = gets.chomp
      end while !TextFormat.entered_correct_choice?(decision)
    
      if decision.downcase == 'y'
        puts `clear`
        player.cards_held << blackjack_deck.deal_card
      end

    end while decision.downcase == 'y'

    if HandTotal.card_total(player.cards_held) > 21
      player.lose_money(bet_placed.to_i)
      TextFormat.print_string "#{player.name} is bust and has lost the game.  #{dealer.name} has won!"
      return
    end
  
    puts `clear`
    loop do
      dealer_total = HandTotal.card_total(dealer.cards_held)
      break if dealer.is_dealer_sticking?(dealer_total)
      TextFormat.print_string "   ********** The dealer is playing... **********"
      show_cards_on_table(dealer.cards_held, player.cards_held)
      sleep 2
      puts `clear`
  
      if HandTotal.card_total(dealer.cards_held) > 21
        show_cards_on_table(dealer.cards_held, player.cards_held)
        player.win_money(bet_placed.to_i)
        TextFormat.print_string "The dealer is bust and has lost the game. #{player.name} has won!"
        return
      end
  
      dealer.cards_held << blackjack_deck.deal_card
    end 

    show_cards_on_table(dealer.cards_held, player.cards_held)
  
    declare_result(bet_placed.to_i)
  

    self.total_cards_played += player.cards_held.size + dealer.cards_held.size

    
  end
  
  def play
    begin
      if player.amount_in_account == 0
        TextFormat.print_string "Your account is empty...the house always wins!"
        TextFormat.print_string "Thanks for playing #{player.name}" 
        return
      end
      game_sequence
      begin
        TextFormat.print_string "Would you like to play again?: Y or N"
        decision = gets.chomp
      end while !TextFormat.entered_correct_choice?(decision)
    end while decision.downcase == 'y'
  
    TextFormat.print_string "Thanks for playing #{player.name}" 
  end
end

GameFlow.new.play
