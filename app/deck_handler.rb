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
  
  #this method allows the hand of cards to be printed horizontally on the screen. The top part of each card is held in card_images[0] down to the last part
  #of each card being held in card_images[4]. Basically, builds a card image up line by line.
  def display_cards(card_array)
    card_images = [[],[],[],[],[]]
    card_array.each do |card|
      card_images.each_index { |index| card_images[index] << make_card_image(card)[index] }
    end
    
    card_images.each do |image_section_of_card|
      puts image_section_of_card.join(" ")
    end
  end
  
  def unturned_card
    ['*','*']
  end
  
  private
  
  def make_card_image(card_array)
    card_image_array = []
    
    card_image_array << "┌─────┐"
    card_image_array << "│#{card_array[1]}    │"
    card_image_array << "│  #{card_array[0]}  │"
    card_image_array << "│    #{card_array[1]}│"
    card_image_array << "└─────┘"
    
    card_image_array
  end
end