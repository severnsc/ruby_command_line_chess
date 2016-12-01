class Piece
	attr_reader :color

	def initialize(color)
		@color = color
	end

end

class Pawn < Piece
	attr_accessor :current_position

	def is_move_legal?(square)
		legal = false
		current_column = @current_position.split('').first
		current_row = @current_position.split('').last.to_i
		#If the pawn is white and on the starting row
		if @color == "white" && current_row == 2 
		   #the move is legal if it is one or two rows greater in the same column
		   legal = true if square.split('').first == current_column && [1,2].include?(square.split('').last.to_i - current_row)
		#If the pawn is black and on the starting row
		elsif @color == "black" && current_row == 7
			#the move is legal if it is one or two rows less in the same column
			legal = true if square.split('').first == current_column && [-1,-2].include?(square.split('').last.to_i - current_row)
		#when the white pawn has moved from the starting position
		elsif @color == "white"
			#the move is legal if it is one row greater in the same column
			legal = true if square.split('').first == current_column && (square.split('').last.to_i - current_row) == 1
		#when the black pawn has moved from the starting position
		elsif @color == "black"
			#the move is legal if it is one row less in the same column
			legal = true if square.split('').first == current_column && (square.split('').last.to_i - current_row) == -1
		end
		legal
	end

end

class Rook < Piece
end

class Knight < Piece
end

class Bishop < Piece
end

class Queen < Piece
end

class King < Piece
end