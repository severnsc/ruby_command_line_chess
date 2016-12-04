require_relative "../lib/pieces.rb"

describe Piece do

	subject(:piece) {Piece.new "black"}

	it "should respond to color" do
		expect(piece).to respond_to(:color)
	end

	it "should be black" do
		expect(piece.color).to eql("black")
	end

	it "should respond to .current_position" do
		expect(piece).to respond_to(:current_position)
	end

	describe Pawn do
		subject(:pawn) {Pawn.new "white"}

		it "should respond to display" do
			expect(pawn).to respond_to(:display)
		end

		it "should print white pawn when white" do
			expect{pawn.display}.to output("♙").to_stdout
		end

		subject(:black_pawn) {Pawn.new "black"}

		it "should print black pawn when black" do
			expect{black_pawn.display}.to output("♟").to_stdout
		end

		context "when in the starting position" do

			current_position = "A2"
			before(:each) {pawn.instance_variable_set(:@current_position, current_position)}

			it "should be able to move 1 space forward from opening position" do
				expect(pawn.is_move_legal?("A3")).to eql(true)
			end

			it "should be able to move 2 spaces forward from opening position" do
				expect(pawn.is_move_legal?("A4")).to eql(true)
			end

		end

		context "after being moved from starting position" do

			current_position = "D3"
			before(:each) {pawn.instance_variable_set(:@current_position, current_position)}

			it "should be able to move 1 space foward from other positions" do
				expect(pawn.is_move_legal?("D4")).to eql(true)
			end

			it "should not be able to move 2 spaces forward from other positions" do
				expect(pawn.is_move_legal?("D5")).to eql(false)
			end

			it "should not be able to move backwards" do
				expect(pawn.is_move_legal?("D2")).to eql(false)
			end

			it "should not be able to move horizontally" do
				expect(pawn.is_move_legal?("C3")).to eql(false)
			end

		end
	end

	describe Rook do
		subject(:rook) {Rook.new "white"}

		it "should respond to display" do
			expect(rook).to respond_to(:display)
		end

		it "should print a white rook when color is white" do
			expect{rook.display}.to output("♖").to_stdout
		end

		subject(:black_rook) {Rook.new "black"}

		it "should print a black rook when color is black" do
			expect{black_rook.display}.to output("♜").to_stdout
		end

		context "when in the starting position" do
			current_position = "A1"
			before(:each) {rook.instance_variable_set(:@current_position, current_position)}

			it "should be able to move up to 7 spaces vertically" do
				expect(rook.is_move_legal?("A8")).to eql(true)
			end

			it "should be able to move up to 7 spaces horizontally" do
				expect(rook.is_move_legal?("H1")).to eql(true)
			end

			it "should not be able to move diagonally" do
				expect(rook.is_move_legal?("B2")).to eql(false)
			end
		end

		context "when not in the starting position" do
			current_position = "D4"
			before(:each) {rook.instance_variable_set(:@current_position, current_position)}

			it "should be able to move backwards" do
				expect(rook.is_move_legal?("D2")).to eql(true)
			end

			it "should be able to move to the left" do
				expect(rook.is_move_legal?("A4")).to eql(true)
			end

			it "should be able to move to the right" do
				expect(rook.is_move_legal?("F4")).to eql(true)
			end
		end

	end

	describe Knight do
		subject(:knight) {Knight.new "white"}

		it "should respond to display" do
			expect(knight).to respond_to(:display)
		end

		it "should print a white knight when color is white" do
			expect{knight.display}.to output("♘").to_stdout
		end

		subject(:black_knight) {Knight.new "black"}

		it "should print a black knight when color is black" do
			expect{black_knight.display}.to output("♞").to_stdout
		end

		current_position = "D4"
		before(:each) {knight.instance_variable_set(:@current_position, current_position)}

		it "should be able to move 2 spaces up and 1 space left" do
			expect(knight.is_move_legal?("C6")).to eql(true)
		end

		it "should be able to move 2 spaces up and 1 space right" do
			expect(knight.is_move_legal?("E6")).to eql(true)
		end

		it "should be able to move 2 spaces left and 1 space up" do
			expect(knight.is_move_legal?("B5")).to eql(true)
		end

		it "should be able to move 2 spaces left and 1 space down" do
			expect(knight.is_move_legal?("B3")).to eql(true)
		end

		it "should be able to move 2 spaces down and 1 space left" do
			expect(knight.is_move_legal?("C2")).to eql(true)
		end

		it "should be able to move 2 spaces down and 1 space right" do
			expect(knight.is_move_legal?("E2")).to eql(true)
		end

		it "should be able to move 2 spaces right and 1 space up" do
			expect(knight.is_move_legal?("F5")).to eql(true)
		end

		it "should be able to move 2 spaces right and 1 space down" do
			expect(knight.is_move_legal?("F3")).to eql(true)
		end

		it "should not be able to move straight backwards" do
			expect(knight.is_move_legal?("D3")).to eql(false)
		end

		it "should not be able to move straight forwards" do
			expect(knight.is_move_legal?("D5")).to eql(false)
		end

		it "should not be able to move straight to the left" do
			expect(knight.is_move_legal?("C4")).to eql(false)
		end

		it "should not be able to move straight to the right" do
			expect(knight.is_move_legal?("E4")).to eql(false)
		end

		it "should not be able to move diagonally" do
			expect(knight.is_move_legal?("E5")).to eql(false)
		end 
	end

	describe Bishop do
		subject(:bishop) {Bishop.new "white"}

		it "should respond to display" do
			expect(bishop).to respond_to(:display)
		end

		it "should print a white bishop when color is white" do
			expect{bishop.display}.to output("♗").to_stdout
		end

		subject(:black_bishop) {Bishop.new "black"}

		it "should print a black bishop when color is black" do
			expect{black_bishop.display}.to output("♝").to_stdout
		end

		context "when in starting position on black square" do

			current_position = "C1"
			before(:each) {bishop.instance_variable_set(:@current_position, current_position)}

			it "should be able to move up 1 left 1" do
				expect(bishop.is_move_legal?("B2")).to eql(true)
			end

			it "should be able to move up 1 right 1" do
				expect(bishop.is_move_legal?("D2")).to eql(true)
			end

			it "should be able to move 2 squares left diagonal" do
				expect(bishop.is_move_legal?("A3")).to eql(true)
			end

			it "should be able to move 5 squares right diagonal" do
				expect(bishop.is_move_legal?("H6")).to eql(true)
			end

			it "shouldn't be able to move up 1" do
				expect(bishop.is_move_legal?("C2")).to eql(false)
			end

			it "shouldn't be able to move left 1" do
				expect(bishop.is_move_legal?("B1")).to eql(false)
			end

			it "shouldn't be able to move right 1" do
				expect(bishop.is_move_legal?("D1")).to eql(false)
			end

			it "shouldn't be able to jump to white square" do
				expect(bishop.is_move_legal?("G2")).to eql(false)
			end

		end

		context "when in the center of the board" do

			current_position = "D4"
			before(:each) {bishop.instance_variable_set(:@current_position, current_position)}

			it "should be able to move down 1 left 1" do
				expect(bishop.is_move_legal?("C3")).to eql(true)
			end

			it "should be able to move down 1 right 1" do
				expect(bishop.is_move_legal?("E3")).to eql(true)
			end

			it "should be able to move down 3 left 3" do
				expect(bishop.is_move_legal?("A1")).to eql(true)
			end

			it "should be able to move down 3 right 3" do
				expect(bishop.is_move_legal?("G1")).to eql(true)
			end

		end
	end

	describe Queen do
		subject(:queen) {Queen.new "white"}

		it "should respond to display" do
			expect(queen).to respond_to(:display)
		end

		it "should print a white queen when color is white" do
			expect{queen.display}.to output("♕").to_stdout
		end

		subject(:black_queen) {Queen.new "black"}

		it "should print a black queen when color is black" do
			expect{black_queen.display}.to output("♛").to_stdout
		end

		current_position = "D4"
		before(:each) {queen.instance_variable_set(:@current_position, current_position)}

		it "should be able to move 4 squares up" do
			expect(queen.is_move_legal?("D8")).to eql(true)
		end

		it "should be able to move 3 squares back" do
			expect(queen.is_move_legal?("D1")).to eql(true)
		end

		it "should be able to move 3 squares left" do
			expect(queen.is_move_legal?("A4")).to eql(true)
		end

		it "should be able to move 4 squares right" do
			expect(queen.is_move_legal?("H4")).to eql(true)
		end

		it "should be able to move 3 left 3 up" do
			expect(queen.is_move_legal?("A7")).to eql(true)
		end

		it "should be able to move 4 right 4 up" do
			expect(queen.is_move_legal?("H8")).to eql(true)
		end

		it "should be able to move 3 left 3 down" do
			expect(queen.is_move_legal?("A1")).to eql(true)
		end

		it "should be able to move 3 right 3 down" do
			expect(queen.is_move_legal?("G1")).to eql(true)
		end

		it "shouldn't be able to move up 2 right 1" do
			expect(queen.is_move_legal?("E6")).to eql(false)
		end
	end

	describe King do
		subject(:king) {King.new "white"}

		current_position = "D4"
		before(:each) {king.instance_variable_set(:@current_position, current_position)}

		it "should be able to move 1 space forward" do
			expect(king.is_move_legal?("D5")).to eql(true)
		end

		it "should be able to move 1 space backwards" do
			expect(king.is_move_legal?("D3")).to eql(true)
		end

		it "should be able to move 1 space left" do
			expect(king.is_move_legal?("C4")).to eql(true)
		end

		it "should be able to move 1 space right" do
			expect(king.is_move_legal?("E4")).to eql(true)
		end

		it "should be able to move 1 space up 1 space left" do
			expect(king.is_move_legal?("C5")).to eql(true)
		end

		it "should be able to move 1 space up 1 space right" do
			expect(king.is_move_legal?("E5")).to eql(true)
		end

		it "should be able to move 1 space down 1 space left" do
			expect(king.is_move_legal?("C3")).to eql(true)
		end

		it "should be able to move 1 space down 1 space right" do
			expect(king.is_move_legal?("E3")).to eql(true)
		end

		it "shouldn't be able to move 3 spaces up" do
			expect(king.is_move_legal?("D7")).to eql(false)
		end

		it "shouldn't be able to move 3 spaces back" do
			expect(king.is_move_legal?("D1")).to eql(false)
		end

		it "shouldn't be able to move 3 spaces left" do
			expect(king.is_move_legal?("A4")).to eql(false)
		end

		it "shouldn't be able to move 3 spaces right" do
			expect(king.is_move_legal?("G4")).to eql(false)
		end

		it "shouldn't be able to move 3 up 3 left" do
			expect(king.is_move_legal?("A7")).to eql(false)
		end

		it "shouldn't be able to move 3 down 3 left" do
			expect(king.is_move_legal?("A1")).to eql(false)
		end

		it "shouldn't be able to move 3 down 3 right" do
			expect(king.is_move_legal?("G1")).to eql(false)
		end

		it "shouldn't be able to move 3 up 3 right" do
			expect(king.is_move_legal?("G7")).to eql(false)
		end

		it "shouldn't be able to move 2 up 1 left" do
			expect(king.is_move_legal?("C6")).to eql(false)
		end
	end

end