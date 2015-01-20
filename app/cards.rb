class Cards
  attr_reader :suits, :values
  def initialize
    @suits = ["\e[31m♥\e[0m", "\e[31m♦\e[0m", '♠', '♣']
    @values = ['A',2,3,4,5,6,7,8,9,'J','Q','K']
  end 
end