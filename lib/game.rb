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
		return "There's no piece there! Try again." unless moving_piece != ""
		return "That's not your piece! Try again." unless moving_piece.color == @current_player.color
		return "You already have a piece there! Try again." if @board.squares[finish] != "" && @board.squares[finish].color == moving_piece.color
		return pawn_capture(moving_piece, start, finish) if moving_piece.is_a?(Pawn) && pawn_legal_capture_distance?(moving_piece, finish)
		return "That move is illegal! Try again." unless moving_piece.is_move_legal?(finish)
		return open_square_move(moving_piece, start, finish) if @board.squares[finish] == ""
		return piece_capture(moving_piece, start, finish) if @board.squares[finish] != ""
	end

	def pawn_legal_capture_distance?(pawn, square)
		legal = false
		landing_distance = []
		landing_distance.push(@board.x_axis.index(square.split('').first) - @board.x_axis.index(pawn.current_column))
		landing_distance.push(square.split('').last.to_i - pawn.current_row)
		if pawn.color == "white"
			legal_distances = [[-1, 1], [1,1]]
			legal = true if legal_distances.include?(landing_distance)
		else
			legal_distances = [[-1, -1], [1, -1]]
			legal = true if legal_distances.include?(landing_distance)
		end
		legal
	end

	def pawn_capture(pawn, start, finish)
		@board.squares[finish].current_position = ""
		@board.squares[finish] = pawn
		@board.squares[start] = ""
		pawn.current_position = finish
		return "#{start.split('').first}x" + finish
	end

	def open_square_move(piece, start, finish)
		@board.squares[finish] = piece
		@board.squares[start] = ""
		piece.current_position = finish
		if piece.is_a? Pawn
			return finish
		elsif piece.is_a? Rook
			return "R" + finish
		elsif piece.is_a? Knight
			return "N" + finish
		elsif piece.is_a? Bishop
			return "B" + finish
		elsif piece.is_a? Queen
			return "Q" + finish
		else
			return "K" + finish
		end
	end

	def piece_capture(piece, start, finish)
		captured_piece = @board.squares[finish]
		captured_piece.current_position = ""
		@board.squares[finish] = piece
		@board.squares[start] = ""
		piece.current_position = finish
		case piece.class
		when Rook
			return "Rx" + finish
		when Knight
			return "Nx" + finish
		when Bishop
			return "Bx" + finish
		when Queen
			return "Qx" + finish
		when King
			return "Kx" + finish
		end
	end
	
end