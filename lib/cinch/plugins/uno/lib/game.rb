# top-level class documentation comment
class Game
  def initialize
    @draw_pile = Deck.new
    @discard_pile = [@draw_pile.pop]
    @players = {}
    @turn = nil
  end
  attr_accessor :draw_pile, :discard_pile, :players, :turn
end
