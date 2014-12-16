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