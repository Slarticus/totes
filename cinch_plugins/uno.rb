require 'cinch'

module Cinch::Plugins
  # top-level class documentation comment
  class Uno
    include Cinch::Plugin

    # top-level class documentation comment
    class Card
      include Cinch::Plugin
      @@suits = %w(red yellow green blue wild)
      @@ranks = ((0..9).to_a.map(&:to_s).concat ['skip', 'reverse', 'draw two'])

      def initialize(suit, rank)
        if (@@suits.include? suit) && (@@ranks.include? rank.to_s)
          @suit, @rank = suit, rank
        elsif (@@suits.include? suit) && (['change color', 'draw four'].include? rank.to_s)
          @suit, @rank = suit, rank
        end
      end
      attr_accessor :suit, :rank

      def to_s
        if @suit != 'wild'
          if @suit == 'blue'
            Format(:royal, "#{@suit} #{@rank}")
          else
            Format(@suit.to_sym, "#{@suit} #{@rank}")
          end
        else
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
    class Deck < Card
      def initialize
        @deck = []
        @@suits.each do |suit|
          if (@@suits.include? suit) && !(suit == 'wild')
            @@ranks.each do |rank|
              @deck << Card.new(suit, rank)
              @deck << Card.new(suit, rank) unless (rank == '0')
            end
          elsif suit == 'wild'
            4.times do
              @deck << Card.new(suit, 'change color')
              @deck << Card.new(suit, 'draw four')
            end
          end
        end
        @deck.shuffle!
      end
      attr_reader :deck

      def to_a
        buffer = []
        @cards.each do |card|
          buffer << card.to_s
        end
        buffer
      end
      
      def to_s
        to_a
      end
    end
    

    module GameController
      class GameController
        def self.start_game
          @game = Game.new
        end

        def self.populate_game
          sleep(5) until @game.population >= 1
        end
        
        def self.stop_game
          @game = nil
        end

        def self.game
          @game
        end

        def self.handle_turns(firstrun=false)
          if firstrun
            @game.turn = @game.players.keys[rand(@game.players.keys.length)]
            # send hand to player
          elsif !firstrun
          end
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
        @hand = Hand.new; 7.times { @hand << GC.game.draw_pile.pop }
      end
      attr_accessor :score, :hand

      def draw_card
        @hand << GC.game.draw_pile.pop
        true
      end

      def play_card(card)
        card = @hand[card.to_i]
        if GC.game.discard_pile.last.cmp(card)
          GC.game.discard_pile << card
          @hand.delete(card)
          true
        else
          false
        end
      end
    end


    # top-level class documentation comment
    class Game
      def initialize
        @draw_pile = Deck.new.deck
        @discard_pile = []; @discard_pile << @draw_pile.pop
        @players = {}
        @turn = nil
      end
      attr_accessor :draw_pile, :discard_pile, :players, :turn

      def join_game(nick)
        @players[nick] = Player.new
      end

      def player(nick)
        @players[nick]
      end

      def population
        @players.keys.length
      end
    end
    

    include GameController
    #---
    match(/start/, method:  :start)
    def start(m)
      GC.start_game
      GC.populate_game
      GC.handle_turns(true)
      m.reply "It's #{GC.game.turn}'s turn. First card: #{GC.game.discard_pile.last.to_s}"
      Target(GC.game.turn).notice GC.game.player(GC.game.turn).hand.readable
    end

    match(/stop/, method:  :stop)
    def stop(m)
      GC.stop_game
    end
    
    match(/join/, method:  :join)
    def join(m)
      GC.game.join_game(m.user.nick)
    end

    match(/hand/, method:  :hand)
    def hand(m)
      Target(m.user.nick).notice GC.game.player(m.user.nick).hand.readable
    end

    match(/draw/, method:  :draw)
    def draw(m)
      drew = lambda { hand(m) }
      drew.call if GC.game.player(m.user.nick).draw_card
    end
    
    match(/play (\S+)/, method:  :play)
    def play(m, card)
      played = lambda { GC.handle_turns; m.reply "It's #{GC.game.turn}'s turn."; last(m) }
      played.call if GC.game.player(m.user.nick).play_card(card)
    end

    match(/last/, method:  :last)
    def last(m)
      m.reply "Last card: #{GC.game.discard_pile.last.to_s}"
    end

  end
end
