require_relative "../lib/pieces.rb"

describe Piece do

	subject(:piece) {Piece.new "black"}

	it "should respond to color" do
		expect(piece).to respond_to(:color)
	end

	it "should be black" do
		expect(piece.color).to eql("black")
	end

	describe Pawn do
		subject(:pawn) {Pawn.new "black"}

		it "should respond to .current_position" do
			expect(pawn).to respond_to(:current_position)
		end

		before(:example) {pawn.current_position = "A2"}

		it "should be able to move 1 space forward from opening position" do
			expect(pawn.is_move_legal?("C2")).to eql(true)
		end

		it "should be able to move 2 spaces forward from opening position" do
			expect(pawn.is_move_legal?("D2")).to eql(true)
		end

		before(:example) {pawn.current_position = "D2"}

		it "should be able to move 1 space foward from other positions" do
			expect(pawn.is_move_legal?("E2")).to eql(true)
		end

		it "should not be able to move 2 spaces forward from other positions" do
			expect(pawn.is_move_legal?("F2")).to eql(false)
		end

		it "should not be able to move backwards" do
			expect(pawn.is_move_legal?("C2")).to eql(false)
		end

		it "should not be able to move horizontally" do
			expect(pawn.is_move_legal)
		end

		it "should be able to take a piece diagonally" do
		end

		it "should receive .promote when it reaches the opponents first row" do
		end

		it "should capture an opposing pawn when en passant" do
		end
	end

	describe Rook do
	end

	describe Knight do
	end

	describe Bishop do
	end

	describe Queen do
	end

	describe King do
	end

end