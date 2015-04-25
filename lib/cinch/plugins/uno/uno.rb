require 'cinch'

module Cinch::Plugins
  class Uno
    lib = "#{Dir.getwd}/lib/cinch/plugins/uno/lib/"
    require_relative lib + 'card.rb'
    require_relative lib + 'deck.rb'
    require_relative lib + 'gamecontroller.rb'
    require_relative lib + 'player.rb'
    require_relative lib + 'game.rb'
    include Cinch::Plugin
    include GameController

    #---
    match(/start/, method:  :start)
    def start(m)
      GC.start_game
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
    #---

  end
end
