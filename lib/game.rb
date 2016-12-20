require_relative "./player.rb"
require_relative "./pieces.rb"
require_relative "./board.rb"

class Game
	attr_reader :board, :current_player

	def initialize(player1, player2)
		player1.is_a?(Player) ? @player1 = player1 : raise(TypeError)
		player2.is_a?(Player) ? @player2 = player2 : raise(TypeError)
		@board = Board.new
		random = rand(0..1)
		if random == 0
			@player1.color = "white"
			@player2.color = "black"
		else
			@player1.color = "black"
			@player2.color = "white"
		end
		@player1.color == "white" ? @current_player = @player1 : @current_player = @player2
	end

	def players
		[@player1, @player2]
	end

	def play_turn(start, finish)
		moving_piece = @board.squares[start]
		if moving_piece.color == @current_player.color && moving_piece.is_move_legal?(finish)
			#If the piece on the destination square is an opposing color
			if @board.squares[finish].color != moving_piece.color
			#If the piece on the destination square is the same color
			elsif @board.squares[finish].color == moving_piece.color
				puts "You already have a piece there! Try again."
				false
			#If the square is open
			else
				@board.squares[finish] = moving_piece
				@board.squares[start] = ""
			end	
		elsif moving_piece.color != @current_player.color
			puts "That's not your piece! Try again."
			false
		else
			puts "That move is illegal! Try again."
			false
		end
	end

	def game_over?
		if @player1.check_mate?
			puts "Game over! Player 2 wins!"
			true
		elsif @player2.check_mate?
			puts "Game over! Player 1 wins!"
			true
		elsif draw?
			puts "Game over! It's a draw!"
			true
		else
			false
		end
	end
	
end