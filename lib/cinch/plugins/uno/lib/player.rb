# top-level class documentation comment
class Player
  class Hand < Array
    def to_s
      buffer = ''
      n = 0
      self.map(&:to_s).each do |i|
        buffer.concat "[#{n}]" + " #{i} "
        n += 1
      end
      buffer
    end
  end

  def initialize
    @score = 0
    @hand = Hand.new # 7.times { @hand << GC.game.draw_pile.pop }; here?
  end
  attr_accessor :score, :hand
end
