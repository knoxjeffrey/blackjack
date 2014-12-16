module Hand
  def receive_card(card)
    cards_held << card
  end
  
  def clear_hand
    self.cards_held = []
  end
end
