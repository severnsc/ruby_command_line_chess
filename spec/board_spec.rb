require_relative "../lib/board.rb"

describe Board do 

	it "should have x-axis markers a-h" do
		expect(Board.new.x_axis).to eql(("a".."h").to_a)
	end

	it "should have y-axis markers 1-8" do
		expect(Board.new.y_axis).to eql((1..8).to_a)
	end

	it "should be 8x8" do
		@board = Board.new
		expect(@board.x_axis.count * @board.y_axis.count).to eql(64) 
	end

	describe ".initialize" do
		it "should create 8 black pawns" do
		end

		it "should create 8 white pawns" do
		end

		it "should create 2 black rooks" do
		end

		it "should create 2 white rooks" do
		end

		it "should create 2 black bishops" do
		end

		it "should create 2 white bishops" do
		end

		it "should create 2 black knights" do
		end

		it "should create 2 white knights" do
		end

		it "should create 1 black queen" do
		end

		it "should create 1 white queen" do
		end

		it "should create 1 black king" do
		end

		it "should crete 1 white king" do
		end
	end

end