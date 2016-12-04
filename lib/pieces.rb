class Piece
	attr_reader :color, :current_position, :current_column, :current_row

	def initialize(color)
		@color = color
	end

end

class Pawn < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		legal = false
		#If the pawn is white and on the starting row
		if @color == "white" && current_row == 2 
		   #the move is legal if it is one or two rows greater in the same column
		   legal = true if square.split('').first.downcase == current_column && [1,2].include?(square.split('').last.to_i - current_row)
		#If the pawn is black and on the starting row
		elsif @color == "black" && current_row == 7
			#the move is legal if it is one or two rows less in the same column
			legal = true if square.split('').first.downcase == current_column && [-1,-2].include?(square.split('').last.to_i - current_row)
		#when the white pawn has moved from the starting position
		elsif @color == "white"
			#the move is legal if it is one row greater in the same column
			legal = true if square.split('').first.downcase == current_column && (square.split('').last.to_i - current_row) == 1
		#when the black pawn has moved from the starting position
		elsif @color == "black"
			#the move is legal if it is one row less in the same column
			legal = true if square.split('').first.downcase == current_column && (square.split('').last.to_i - current_row) == -1
		end
		legal
	end

	def display
		if @color == "white"
			print "♙"
		else
			print "♟"
		end
	end

end

class Rook < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		legal = false
		#move is legal if the column stays the same and the new row is 1-7 rows away
		legal = true if square.split('').first.downcase == current_column && (1..7).include?((square.split('').last.to_i - current_row).abs)	
		#move is legal if the row stays the same and the new column is 1-7 columns away
		legal = true if ("a".."h").include?(square.split('').first.downcase) && square.split('').last.to_i == current_row && square.split('').first.downcase != current_column
		legal
	end

end

class Knight < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		x_values = ("a".."h").to_a
		legal = false
		x_dist = (x_values.index(square.split('').first.downcase) - x_values.index(@current_column)).abs
		y_dist = (square.split('').last.to_i - @current_row).abs
		legal = true if [1,2].include?(x_dist) && [1,2].include?(y_dist) && x_dist != y_dist
		legal
	end

end

class Bishop < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		x_values = ("a".."h").to_a
		legal = false
		x_dist = (x_values.index(square.split('').first.downcase) - x_values.index(@current_column)).abs
		y_dist = (square.split('').last.to_i - @current_row).abs
		legal = true if x_dist == y_dist
		legal
	end

end

class Queen < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		x_values = ("a".."h").to_a
		legal = false
		x_dist = (x_values.index(square.split('').first.downcase) - x_values.index(@current_column)).abs
		y_dist = (square.split('').last.to_i - @current_row).abs
		legal = true if square.split('').first.downcase == current_column && (1..7).include?((square.split('').last.to_i - current_row).abs)
		legal = true if ("a".."h").include?(square.split('').first.downcase) && square.split('').last.to_i == current_row && square.split('').first.downcase != current_column
		legal = true if x_dist == y_dist
		legal
	end

end

class King < Piece

	def is_move_legal?(square)
		@current_column = @current_position.split('').first.downcase
		@current_row = @current_position.split('').last.to_i
		x_values = ("a".."h").to_a
		legal = false
		x_dist = (x_values.index(square.split('').first.downcase) - x_values.index(@current_column)).abs
		y_dist = (square.split('').last.to_i - @current_row).abs
		legal = true if x_dist == 1 && y_dist == 1
		legal = true if x_dist == 1 && y_dist == 0
		legal = true if x_dist == 0 && y_dist == 1
		legal
	end

end