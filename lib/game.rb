require_relative "./player.rb"
require_relative "./pieces.rb"
require_relative "./board.rb"

class Game
	attr_reader :board, :current_player

	def initialize(player1, player2)
		player1.is_a?(Player) ? @player1 = player1 : raise(TypeError)
		player2.is_a?(Player) ? @player2 = player2 : raise(TypeError)
		@board = Board.new
		rand(0..1) == 0 ? @player1.color = "white" && @player2.color = "black" : @player1.color = "black" && @player2.color = "white"
		@current_player = players.select {|p| p.color == "white"}
	end

	def players
		[@player1, @player2]
	end
	
end