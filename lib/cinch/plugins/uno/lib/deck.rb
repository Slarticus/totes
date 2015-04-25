# top-level class documentation comment
class Deck < Array
  def initialize
    suits = %w(red yellow green blue wild)
    ranks = %w(0 1 2 3 4 5 6 7 8 9) + ['skip', 'reverse', 'draw two']
    suits.each do |suit|
      if (suits.include? suit) && !(suit == 'wild')
        ranks.each do |rank|
          self << Card.new(suit, rank)
          self << Card.new(suit, rank) unless (rank == '0')
        end
      elsif suit == 'wild'
        4.times do
          self << Card.new(suit, 'change color')
          self << Card.new(suit, 'draw four')
        end
      end
    end
    self.shuffle!
  end

  def to_s
    self.map(&:to_s)
  end
end
