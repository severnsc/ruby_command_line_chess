require_relative "./player.rb"
require_relative "./pieces.rb"
require_relative "./board.rb"

class Game

	def initialize(player1, player2)
		player1.is_a?(Player) ? @player1 = player1 : raise(TypeError)
		player2.is_a?(Player) ? @player2 = player2 : raise(TypeError)
	end

	def players
		[@player1, @player2]
	end
	
end