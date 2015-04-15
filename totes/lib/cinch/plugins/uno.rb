# Behold, the ugliest code in the universe.

require 'cinch'

module Cinch::Plugins
  class Uno
    include Cinch::Plugin

	class Card
	  def initialize(suite, face)
	    @suite = suite
	    @face = face
	  end

	  def readable
	    "#{@suite} #{@face}"
	  end

	  attr_reader :suite

	  attr_reader :face
	end

	class Deck
	  def make_suite(suite)
	    @cards = []
	    (0..12).each do |i|
	      if i == 10
		@cards += [Card.new(suite, :skip)]
	      elsif i == 11
		@cards += [Card.new(suite, :reversal)]
	      elsif i == 12
		@cards += [Card.new(suite, :draw_two)]
	      else
		@cards += [Card.new(suite, i)]
	      end
	    end
	    (1..12).each do |i|
	      if i == 10
		@cards += [Card.new(suite, :skip)]
	      elsif i == 11
		@cards += [Card.new(suite, :reversal)]
	      elsif i == 12
		@cards += [Card.new(suite, :draw_two)]
	      else
		@cards += [Card.new(suite, i)]
	      end
	    end
	    @cards += [Card.new(:wild, :change_color)]
	    @cards += [Card.new(:wild, :draw_four)]
	    @cards
	  end

	  def initialize
	    colors = [:red, :green, :blue, :yellow]
	    @deck = []
	    colors.each do |i|
	      @deck += make_suite(i)
	    end
	  end

	  def deal_hand
	    hand = []
	    7.times { hand += [@deck[rand(@deck.length)]] }
	    @deck -= hand
	    hand
	  end

	  attr_reader :deck
	end

	match(/startgame/, method:  :startgame)
	def startgame(m)
	  $game = true
	  while $game == true
	    if $hands.keys.length >= 1 # change to 2
	      m.reply 'Game started!'
	      $turn = $hands.keys[rand($hands.keys.length)]
	      break
	    else
	    end
	  end
	  $drawPile.concat $deck.deck.shuffle!
	  $discardPile << $drawPile.pop
	  m.reply "Discard pile: #{($discardPile.last).readable}"
	end
	
	match(/endgame/, method:  :endgame)
	def endgame(m)
	  $game = false
	  m.reply 'Game ended'
	end

	match(/join/, method:  :join)
	def join(m)
	  if ($hands.keys.length <= 10)
	    $hands[m.user.nick] = $deck.deal_hand
	    if $game == true
	      m.reply "#{m.user.nick} has joined the game! #{10 - $hands.keys.length} spots remaining!"
	    end
	  else
	  end
	end
	
	match(/hand/, method:  :hand)
	def hand(m)
	  if $hands.key? m.user.nick
	    buffer = []
	    $hands[m.user.nick].each do |card|
	      buffer << card.readable
	    end
	    n = 0
	    buffer.each do |i|
	      buffer[buffer.index i] = "[#{n}] #{i}"
	      n += 1
	    end
	    m.reply "#{m.user.nick}: #{buffer.join(', ')}"
	  end
	end

	match(/status/, method:  :status)
	def status(m)
	  if $game == true
	    m.reply 'A game is heppen nao'
	  elsif $game == false
	    m.reply 'No game is heppen nao'
	  end
	end

	match(/uno/, method:  :declare_uno)
	def declare_uno(m)
	end

	match(/draw/, method:  :draw)
	def draw(m)
		$hands[m.user.nick] << $drawPile.pop
		m.reply "#{m.user.nick} drew a card."
	end

	match(/pile/, method:  :pile)
	def pile(m)
		m.reply "#{$discardPile.last.readable}"
	end

	match(/play (\S+)/, method:  :play)
	def play(m, card)
	  if ($game == true) && ($turn == m.user.nick)

	    card = $hands[m.user.nick][card.to_i]
	    if (card.face == $discardPile.last.face) or (card.suite == $discardPile.last.suite)
	      $discardPile << card
	      $hands[m.user.nick].delete card
	      m.reply "#{m.user.nick} played #{card.readable}"

	      if !([:skip, :reversal, :draw_two].include? card.face)
		$turn = $hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]

	      elsif [:skip, :reversal, :draw_two].include? card.face

		if card.face == :skip
		  $turn = $hands.keys[($hands.keys.index(m.user.nick) + 2) % $hands.keys.length]
		  m.reply "#{$hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]}'s turn was skipped"

		elsif card.face == :reversal
		  m.reply 'do whatever a reversal does'
		  $turn = $hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length] # TEMPORARY

		elsif card.face == :draw_two
		  $hands[$hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]] << $drawPile.pop
		  $hands[$hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]] << $drawPile.pop
		  m.reply "#{$hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]} drew two cards"
		  $turn = $hands.keys[($hands.keys.index(m.user.nick) + 1) % $hands.keys.length]

		elsif card.face == :change_color # needs user input

		elsif card.face == :draw_four

		end

	      end

	    else
	      m.reply 'Invalid card TEST'
	      # debug stuff:
	      m.reply 'DEBUG: '
	      m.reply card.readable
	      p $discardPile
	      m.reply '/DEBUG'

	    end

	  elsif ($game == true) && !($turn == m.user.nick)
	    m.reply "It's not your turn, #{m.user.nick}"

	  end
	  m.reply "It's #{$turn}'s turn."
	  m.reply "Discard pile: #{$discardPile.last.readable}"
	end

	$deck = Deck.new
	$game = false
	$hands = {}
	$drawPile = []
	$discardPile = []

	while $game == true
		$hands[$turn].each do |card|
		end
	end
  end
end

# need draw/autodraw functionality
# autodraw, uno truth check/revert
