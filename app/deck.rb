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