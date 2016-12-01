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
		subject(:pawn) {Pawn.new "white"}

		it "should respond to .current_position" do
			expect(pawn).to respond_to(:current_position)
		end

		context "when in the starting position" do

			before(:each) {pawn.current_position = "A2"}

			it "should be able to move 1 space forward from opening position" do
				expect(pawn.is_move_legal?("A3")).to eql(true)
			end

			it "should be able to move 2 spaces forward from opening position" do
				expect(pawn.is_move_legal?("A4")).to eql(true)
			end

		end

		context "after being moved from starting position" do

			before(:each) {pawn.current_position = "D3"}

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