# top-level class documentation comment
class Card
  include Cinch::Plugin

  def initialize(suit, rank)
    @suit, @rank = suit, rank
  end
  attr_accessor :suit, :rank

  def to_s
    if @suit == 'blue'
      Format(:royal, "#{@suit} #{@rank}")
    elsif suit == 'wild'
      buffer = []
      n = 0
      colors = [:red, :orange, :yellow, :green, :royal, :purple]
      "#{@suit} #{@rank}".each_char do |i|
        if i != ' '
          buffer << Format(colors[n % colors.length], i)
        elsif i == ' '
          buffer << i
        end
        n += 1
      end
      buffer.join
    else
      Format(@suit.to_sym, "#{@suit} #{@rank}")
    end
  end

  def cmp(card)
    if (@suit == card.suit) || (@rank == card.rank)
      true
    elsif (card.suit == 'wild') || (@suit == 'wild')
      true
    end
  end
end
