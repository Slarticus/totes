module GameController
  class GameController
    def self.start_game
      @game = Game.new
    end

    def self.populate_game
    end
    
    def self.stop_game
      @game = nil
    end

    def self.game
      @game
    end

    def self.handle_turns(first=false)
    end
  end
  GC = GameController
end
