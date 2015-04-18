require 'cinch'

module Cinch::Plugins
  class Uno
    include Cinch::Plugin

    class Card
      include Cinch::Plugin

      def initialize(suite, face)
        @suite = suite
        @face = face
      end

      def readable
        if @suite != :wild
          Format(@suite, "#{@suite} #{@face}")
        else
          buffer = []
          n = 0
          colors = [:red, :orange, :yellow, :green, :turquoise, :blue, :purple] 
          "#{@suite} #{@face}".each_char do |i|
            buffer << Format(colors[n % colors.length], i)
            n += 1
          end
          buffer.join()
        end
      end
      attr_accessor :suite, :face
    end

    class Deck
      def initialize
        @deck = []
        colors = [:red, :green, :blue, :yellow]
        colors.each do |color|
          (0..12).each do |i|
            if i == 10
              @deck << Card.new(color, :skip)
            elsif i == 11
              @deck << Card.new(color, :reversal)
            elsif i == 12
              @deck << Card.new(color, :draw_two)
            else
              @deck << Card.new(color, i)
            end
          end
          (1..12).each do |i|
            if i == 10
              @deck << Card.new(color, :skip)
            elsif i == 11
              @deck << Card.new(color, :reversal)
            elsif i == 12
              @deck << Card.new(color, :draw_two)
            else
              @deck << Card.new(color, i)
            end
          end
          @deck << Card.new(:wild, :change_color)
          @deck << Card.new(:wild, :draw_four)
        end
        @deck.shuffle!
      end
      attr_reader :deck
    end

    class Player
      def initialize(name)
        @name = name
        @score = 0
        @hand = []; 7.times { @hand << Uno.class_variable_get(:@@drawPile).pop }
      end
      attr_reader :name, :score, :hand
    end

    @@players = {}
    @@first_run = true

    def start(m)
      @game = true
      @@drawPile = Deck.new.deck
      @@discardPile = []; @@discardPile << @@drawPile.pop
      if @@first_run == true
        if @@players.keys.length < 1 # TODO CHANGE TO 2; they smell after dancing for too long
          m.reply "Waiting for #{2 - @@players.keys.length} more players to join..."
        elsif (@@players.keys.length >= 1) # TODO CHANGE TO 2
          @turn = @@players.keys[rand(@@players.keys.length)]
          m.reply 'Starting game...'
          m.reply "It's #{@turn}'s turn. First card: #{@@discardPile.last.readable}"
          hand(m)
          @@first_run = false
        end
      end
    end

    def stop(m)
      @game = false
      @@drawPile = []; @@discardPile = []; @@players = {}; @turn = nil
      @@first_run = true
      m.reply 'Game stopped.'
    end

    def join(m)
      if (@game == true) && (@@players.keys.length < 10) && !(@@players.keys.include? m.user.nick)
        @@players[m.user.nick] = Player.new(m.user.nick)
        m.reply "#{m.user.nick} has joined the game! #{10 - @@players.length} spots remaining."
        start(m)
      elsif (@game == true) && (@@players.keys.length == 10)
        m.reply 'The game is full!'
      else
        m.reply "(#{m.user.nick}) There is no game going on right now."
      end
    end

    def hand(m)
      if (@game == true) && (@@players.key? m.user.nick)
        n = 0
        buffer = []
        @@players[m.user.nick].hand.map(&:readable).each do |i|
          buffer.concat ["[#{n}] " + i]
          n += 1
        end
        m.reply buffer.join(', ')
      end
    end

    def play(m, card)
      real_card = @@players[m.user.nick].hand[card.to_i]
      player_index = @@players.keys.index(m.user.nick)

      if (@game == true) && (@turn == m.user.nick) && (card.to_i <= @@players[m.user.nick].hand.length) && (card.to_i >= 0) && ((@color == false) || (@color == nil))
        if (@@discardPile.last.suite == real_card.suite) || (@@discardPile.last.face == real_card.face)

          # special faces
          if real_card.face == :skip
            @turn = @@players.keys[(player_index + 2) % @@players.keys.length]
            m.reply "#{@@players.keys[(player_index + 1) % @@players.keys.length]}'s turn was skipped."

          elsif real_card.face == :draw_two
            2.times { @@players[@@players.keys[(player_index + 1) % @@players.keys.length]].hand << @@drawPile.pop }
            m.reply "#{@@players.keys[(player_index + 1) % @@players.keys.length]} drew two cards."

          elsif real_card.face == :reversal

          else
            @turn = @@players.keys[(player_index + 1) % @@players.keys.length]
          end
          # /special faces: covert ops
          
          @@discardPile << real_card
          @@players[m.user.nick].hand.delete real_card
          m.reply "It's #{@turn}'s turn. Last played: #{@@discardPile.last.readable}"
        elsif real_card.suite == :wild
          if real_card.face == :change_color
            @color = true
            m.reply "#{m.user.nick}, use !color <color name> to change the suite."
          elsif real_card.face == :wild_draw_four
            # how are you going to take user input?
          end
          @@discardPile << real_card unless real_card.face == :change_color
          @@players[m.user.nick].hand.delete real_card
        end
      hand(m)
      else
      end
    end

    def draw(m)
      @@players[m.user.nick].hand << @@drawPile.pop
      m.reply "#{m.user.nick} drew a card."
      hand(m)
    end

    def color(m, color)
      color = color.to_sym
      player_index = @@players.keys.index(m.user.nick)
      if (@color == true) && (@turn == m.user.nick)
        @@discardPile.last.suite = color
          @turn = @@players.keys[(player_index + 1) % @@players.keys.length]
          @color = false
          m.reply "Suite changed: #{@@discardPile.last.readable}. It's #{@turn}'s turn."
      end
    end

    def pile(m)
      if @game == true
        m.reply @@discardPile.last.readable
      end
    end

    def points(m)
    end

    match(/start/, method:  :start)
    match(/stop/, method:  :stop)
    match(/join/, method:  :join)
    match(/hand/, method:  :hand)
    match(/play (\S+)/, method:  :play)
    match(/draw/, method:  :draw)
    match(/color (\S+)/, method:  :color)
    match(/pile/, method:  :pile)
    match(/points/, method:  :points)
  end
end

# needs autodraw; draw until player has valid card
