require_relative "../lib/board.rb"

describe Board do 

	it "should have x-axis markers a-h" do
		expect(Board.new.x_axis).to eql(("A".."H").to_a)
	end

	it "should have y-axis markers 1-8" do
		expect(Board.new.y_axis).to eql((1..8).to_a)
	end

	it "should be 8x8" do
		@board = Board.new
		expect(@board.x_axis.count * @board.y_axis.count).to eql(64) 
	end

	describe ".initialize" do
		subject(:board){Board.new}

		context "when creating the pieces" do

			it "should receive create_pawns with argument black" do
				expect(board).to receive(:create_pawns).with("black")
				board.create_pawns("black")
			end

			before(:example) {board.create_pawns("black")}

			it "should create 8 black pawns" do
				expect(board.squares.values.count {|a| a.is_a?(Pawn) && a.color == "black"}).to eql(8)
			end

			it "should receive create_rooks with argument black" do
				expect(board).to receive(:create_rooks).with("black")
				board.create_rooks("black")
			end

			before(:example) {board.create_rooks("black")}

			it "should create 2 black rooks" do
				expect(board.squares.values.count {|a| a.is_a?(Rook) && a.color == "black"}).to eql(2)
			end

			it "should receieve create bishops with argument black" do
				expect(board).to receive(:create_bishops).with("black")
				board.create_bishops("black")
			end

			before(:example) {board.create_bishops("black")}

			it "should create 2 black bishops" do
				expect(board.squares.values.count {|a| a.is_a?(Bishop) && a.color == "black"}).to eql(2)
			end

			it "should receive create_knights with argument black" do
				expect(board).to receive(:create_knights).with("black")
				board.create_knights("black")
			end

			before(:example) {board.create_knights("black")}

			it "should create 2 black knights" do
				expect(board.squares.values.count {|a| a.is_a?(Knight) && a.color == "black"}).to eql(2)
			end

			it "should receive create_queen with argument black" do
				expect(board).to receive(:create_queen).with("black")
				board.create_queen("black")
			end

			before(:example) {board.create_queen("black")}

			it "should create 1 black queen" do
				expect(board.squares.values.count {|a| a.is_a?(Queen) && a.color == "black"}).to eql(1)
			end

			it "should receive create_king with argument black" do
				expect(board).to receive(:create_king).with("black")
				board.create_king("black")
			end

			before(:example) {board.create_king("black")}

			it "should create 1 black king" do
				expect(board.squares.values.count {|a| a.is_a?(King) && a.color == "black"}).to eql(1)
			end

		end

		context "when placing pieces on the board" do

			let(:black_pawn_squares) {["A7", "B7", "C7", "D7", "E7", "F7", "G7", "H7"]}
			let(:white_pawn_squares) {["A2", "B2", "C2", "D2", "E2", "F2", "G2", "H2"]}
			let(:black_rook_squares) {["A8", "H8"]}
			let(:white_rook_squares) {["A1", "H1"]}
			let(:black_knight_squares) {["B8", "G8"]}
			let(:white_knight_squares) {["B1", "G1"]}
			let(:black_bishop_squares) {["C8", "F8"]}
			let(:white_bishop_squares) {["C1", "F1"]}

			it "should place the black pawns across row 7" do
				expect(black_pawn_squares.all? {|sp| board.squares[sp].is_a?(Pawn) && board.squares[sp].color == "black"}).to eql(true)
			end

			it "should place the white pawns across row 2" do
				expect(white_pawn_squares.all? {|sp| board.squares[sp].is_a?(Pawn) && board.squares[sp].color == "white"}).to eql(true)
			end

			it "should place the black rooks at A8 and H8" do
				expect(black_rook_squares.all? {|sp| board.squares[sp].is_a?(Rook) && board.squares[sp].color == "black"}).to eql(true)
			end

			it "should place the white rooks at A1 and H1" do
				expect(white_rook_squares.all? {|sp| board.squares[sp].is_a?(Rook) && board.squares[sp].color == "white"}).to eql(true)
			end

			it "should place the black knights at B8 and G8" do
				expect(black_knight_squares.all? {|sp| board.squares[sp].is_a?(Knight) && board.squares[sp].color == "black"}).to eql(true)
			end

			it "should place the white knights at B1 and G1" do
				expect(white_knight_squares.all? {|sp| board.squares[sp].is_a?(Knight) && board.squares[sp].color == "white"}).to eql(true)
			end

			it "should place the black bishops at C8 and F8" do
				expect(black_bishop_squares.all? {|sp| board.squares[sp].is_a?(Bishop) && board.squares[sp].color == "black"}).to eql(true)
			end

			it "should place the white bishops at C1 and F1" do
				expect(white_bishop_squares.all? {|sp| board.squares[sp].is_a?(Bishop) && board.squares[sp].color == "white"}).to eql(true)
			end

			it "should place the black queen at D8" do
				expect(board.squares["D8"].is_a?(Queen) && board.squares["D8"].color == "black").to eql(true)
			end

			it "should place the white queen at D1" do
				expect(board.squares["D1"].is_a?(Queen) && board.squares["D1"].color == "white").to eql(true)
			end

			it "should place the black king at E8" do
				expect(board.squares["E8"].is_a?(King) && board.squares["E8"].color == "black").to eql(true)
			end

			it "should place the white king at E1" do
				expect(board.squares["E1"].is_a?(King) && board.squares["E1"].color == "white").to eql(true)
			end
		end

	end

end