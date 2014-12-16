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