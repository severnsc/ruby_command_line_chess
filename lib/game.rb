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
		if moving_piece == ""
			puts "There's no piece there! Try again."
		elsif moving_piece.color != @current_player.color
			puts "That's not your piece! Try again."
		elsif @board.squares[finish] != "" && @board.squares[finish].color == moving_piece.color
			puts "You already have a piece there! Try again."
		elsif moving_piece.is_a?(Pawn) && pawn_legal_capture_distance?(moving_piece, finish)
			pawn_capture(moving_piece, start, finish)
			@current_player = players.select {|p| p != @current_player}[0]
		elsif !moving_piece.is_move_legal?(finish)
			puts "That move is illegal! Try again."
		elsif @board.squares[finish] == ""
			open_square_move(moving_piece, start, finish)
		elsif @board.squares[finish] != ""
			piece_capture(moving_piece, start, finish)
		end
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
		puts "#{start.split('').first}x" + finish
	end

	def open_square_move(piece, start, finish)
		@board.squares[finish] = piece
		@board.squares[start] = ""
		piece.current_position = finish
		if piece.is_a? Pawn
			puts finish
		elsif piece.is_a? Rook
			puts "R" + finish
		elsif piece.is_a? Knight
			puts "N" + finish
		elsif piece.is_a? Bishop
			puts "B" + finish
		elsif piece.is_a? Queen
			puts "Q" + finish
		else
			puts "K" + finish
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
			puts "Rx" + finish
		when Knight
			puts "Nx" + finish
		when Bishop
			puts "Bx" + finish
		when Queen
			puts "Qx" + finish
		when King
			puts "Kx" + finish
		end
	end
	
end