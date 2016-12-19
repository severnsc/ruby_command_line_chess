require_relative "./pieces.rb"

class Board

	attr_reader :squares, :pawns, :rooks, :knights, :bishops, :queens, :kings

	@@x_axis = ("a".."h").to_a
	@@y_axis = (1..8).to_a

	def initialize
		@pawns = []
		@rooks = []
		@knights = []
		@bishops = []
		@queens = []
		@kings = []
 		create_pawns("black")
		create_pawns("white")
		create_rooks("black")
		create_rooks("white")
		create_bishops("black")
		create_bishops("white")
		create_knights("black")
		create_knights("white")
		create_queen("black")
		create_queen("white")
		create_king("black")
		create_king("white")
		@squares = Hash.new
		@@x_axis.each do |x|
			@@y_axis.each do |y|
				@squares[x+y.to_s] = ""
			end
		end
		black_pawn_squares = ["A7", "B7", "C7", "D7", "E7", "F7", "G7", "H7"]
		black_pawns = @pawns.select {|pawn| pawn.color == "black"}
		black_pawn_squares.each_with_index {|sq, index| @squares[sq] = black_pawns[index]}
		white_pawn_squares = ["A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2"]
		white_pawns = @pawns.select {|pawn| pawn.color == "white"}
		white_pawn_squares.each_with_index {|sq, index| @squares[sq] = white_pawns[index]}
		black_rook_squares = ["A8", "H8"]
		black_rooks = @rooks.select {|rook| rook.color == "black"}
		black_rook_squares.each_with_index {|sq, index| @squares[sq] = black_rooks[index]}
		white_rook_squares = ["A1", "H1"]
		white_rooks = @rooks.select {|rook| rook.color == "white"}
		white_rook_squares.each_with_index {|sq, index| @squares[sq] = white_rooks[index]}
		black_knight_squares = ["B8", "G8"]
		black_knights = @knights.select {|knight| knight.color == "black"}
		black_knight_squares.each_with_index {|sq, index| @squares[sq] = black_knights[index]}
		white_knight_squares = ["B1", "G1"]
		white_knights = @knights.select {|knight| knight.color == "white"}
		white_knight_squares.each_with_index {|sq, index| @squares[sq] = white_knights[index]}
		black_bishop_squares = ["C8", "F8"]
		black_bishops = @bishops.select {|bishop| bishop.color == "black"}
		black_bishop_squares.each_with_index {|sq, index| @squares[sq] = black_bishops[index]}
		white_bishop_squares = ["C1", "F1"]
		white_bishops = @bishops.select {|bishop| bishop.color == "white"}
		white_bishop_squares.each_with_index {|sq, index| @squares[sq] = white_bishops[index]}
		black_queen = @queens.select {|queen| queen.color == "black"}
		@squares["D8"] = black_queen[0]
		white_queen = @queens.select {|queen| queen.color == "white"}
		@squares["D1"] = white_queen[0]
		black_king = @kings.select {|king| king.color == "black"}
		@squares["E8"] = black_king[0]
		white_king = @kings.select {|king| king.color == "white"}
		@squares["E1"] = white_king
	end

	def x_axis
		@@x_axis
	end

	def y_axis
		@@y_axis
	end

	def create_pawns(color)
		8.times {|i| @pawns.push(Pawn.new color)}
		@pawns
	end

	def create_rooks(color)
		2.times {|i| @rooks.push(Rook.new color)}
		@rooks
	end

	def create_bishops(color)
		2.times {|i| @bishops.push(Bishop.new color)}
		@bishops
	end

	def create_knights(color)
		2.times {|i| @knights.push(Knight.new color)}
		@knights
	end

	def create_queen(color)
		@queens.push(Queen.new color)
		@queens
	end

	def create_king(color)
		@kings.push(King.new color)
		@kings
	end

end