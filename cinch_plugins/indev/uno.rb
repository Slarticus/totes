require 'cinch'

module Cinch::Plugins
  # top-level class documentation comment
  class Uno
    include Cinch::Plugin

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

    module GameController
      class GameController
        def self.start_game
          @game = Game.new
        end
        
        def self.stop_game
          @game = nil
        end

        def self.game
          @game
        end
      end

      GC = GameController
    end

    # top-level class documentation comment
    class Player
      include GameController
      
      class Hand < Array
        def readable
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
    

    include GameController
    #---
    match(/start/, method:  :start)
    def start(m)
      GC.start_game
      GC.populate_game
      GC.handle_turns(true)
    end

    match(/stop/, method:  :stop)
    def stop(m)
      GC.stop_game
    end
    
    match(/join/, method:  :join)
    def join(m)
    end

    match(/hand/, method:  :hand)
    def hand(m)
    end

    match(/draw/, method:  :draw)
    def draw(m)
    end
    
    match(/play (\S+)/, method:  :play)
    def play(m, card)
    end

    match(/last/, method:  :last)
    def last(m)
    end

  end
end
