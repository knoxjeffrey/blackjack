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
