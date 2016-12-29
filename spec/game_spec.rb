require_relative "../lib/game.rb"

describe Game do

	before(:each) do
		@player1 = Player.new "player1"
		@player2 = Player.new "player2"
		@game = Game.new(@player1, @player2)
		@board = @game.board
	end

	context "when starting a new game" do

		context "given incorrect arguments" do

			it "raises a TypeError" do
				expect{Game.new("player1", "player2")}.to raise_error
			end

		end

		context "given the correct arguments" do

			it "creates a new Game object" do
				expect(@game.is_a?(Game)).to eql(true)
			end

			it "adds the new players to the game" do
				expect(@game.players).to eql([@player1, @player2])
			end

			it "creates a new board" do
				expect(@game.board.is_a?(Board)).to eql(true) 
			end

			it "sets the player who has color white to go first" do
				expect(@game.current_player.color).to eql("white")
			end

		end
	end

	describe ".play_turn" do

		before(:each) do
			current_player = @game.players.select {|p| p.color == "black"}
			@game.instance_variable_set(:@current_player, current_player[0])
		end

		context "when start square is empty" do
			it "prints a message stating that there's no piece there" do
				expect{@game.play_turn("A4", "A5")}.to output("There's no piece there! Try again.\n").to_stdout
			end
		end

		context "when moving piece isn't the same color as the current player" do
			it "prints a message stating that the piece the player is attempting to move doesn't belong to them" do
				expect{@game.play_turn("A2", "A3")}.to output("That's not your piece! Try again.\n").to_stdout
			end
		end

		context "when attempting to move a piece to a square where a different piece of the same color already is" do
			it "prints a message stating that the player already has a piece on that square" do
				expect{@game.play_turn("A8", "A7")}.to output("You already have a piece there! Try again.\n").to_stdout
			end
		end

		context "when a piece is in the way of the desitnation square" do
			before(:each) do
				@black_pawn = Pawn.new "black"
				@board.squares["A6"] = @black_pawn
			end

			it "prints a message stating that there is a piece in the way" do
				expect{@game.play_turn("A7", "A5")}.to output("There's a piece in the way! Try again.\n").to_stdout
			end
		end

		context "when move is illegal" do
			it "prints a message stating that the move is illegal" do
				expect{@game.play_turn("A7", "A4")}.to output("That move is illegal! Try again.\n").to_stdout
			end
		end

		context "when performing a pawn capture" do
			before(:each) {@board.squares["B6"] = Pawn.new "white"}

			it "prints the algebraic notation of the capture" do
				expect{@game.play_turn("A7", "B6")}.to output("AxB6\n").to_stdout
			end

			it "updates the current player to the player of the opposing color" do
				@game.play_turn("A7", "B6")
				expect(@game.current_player).to eql(@game.players.select {|p| p.color=="white"}[0])
			end
		end

		context "when moving a pawn to an open square" do

			it "prints the algebraic notation of the move" do
				expect{@game.play_turn("A7", "A6")}.to output("A6\n").to_stdout
			end
		end

		context "when capturing a piece with a rook" do
			before(:each) do
				@black_rook = Rook.new "black"
				@board.squares["C6"] = @black_rook
				@black_rook.current_position = "C6"
				@black_rook.update_row_column
				@white_pawn = Pawn.new "white"
				@board.squares["C5"] = @white_pawn
				@white_pawn.current_position = "C5"
				@white_pawn.update_row_column
			end

			it "prints the algebraic notation of the capture" do
				expect{@game.play_turn("C6", "C5")}.to output("RxC5\n").to_stdout
			end

			it "updates the current player to the player of opposing color" do
				@game.play_turn("C6", "C5")
				expect(@game.current_player).to eql(@game.players.select {|p| p.color=="white"}[0])
			end
		end

	end

	describe ".pawn_legal_capture_distance?" do
		subject(:black_pawn) {@board.squares["A7"]}

		context "when moving a black pawn from A7 to B6" do
			it "returns true" do
				expect(@game.pawn_legal_capture_distance?(black_pawn, "B6")).to eql(true)
			end
		end

	end

	describe ".pawn_capture" do
		before(:each) do
			current_player = @game.players.select {|p| p.color == "black"}
			@game.instance_variable_set(:@current_player, current_player[0])
			@white_pawn = Pawn.new "white"
			@board.squares["B6"] = @white_pawn
			@capturing_pawn = @board.squares["A7"]
			@capturing_pawn.update_row_column
		end

		before(:each) {@game.pawn_capture(@capturing_pawn, "A7", "B6")}

		it "updates the current position of the captured piece to ''" do
			expect(@white_pawn.current_position).to eql("")
		end

		it "sets the finish square equal to the capturing pawn" do
			expect(@board.squares["B6"]).to eql(@capturing_pawn)
		end

		it "clears the start square setting it equal to ''" do
			expect(@board.squares["A7"]).to eql("")
		end

		it "updates the capturing pawn's current position to the finish square" do
			expect(@capturing_pawn.current_position).to eql("B6")
		end

	end

	describe ".open_square_move" do
		before(:each) do
			@moving_piece = @board.squares["A7"]
			@game.open_square_move(@moving_piece, "A7", "A6")
		end

		it "sets the finish square equal to the moving piece" do
			expect(@board.squares["A6"]).to eql(@moving_piece)
		end

		it "clears the start square and sets it equal to ''" do
			expect(@board.squares["A7"]).to eql("")
		end

		it "updates the moving piece's current position" do
			expect(@moving_piece.current_position).to eql("A6")
		end
	end

	describe ".piece_capture" do
		before(:each) do
			@black_rook = Rook.new "black"
			@board.squares["C6"] = @black_rook
			@black_rook.current_position = "C6"
			@black_rook.update_row_column
			@white_pawn = Pawn.new "white"
			@board.squares["C5"] = @white_pawn
			@white_pawn.current_position = "C5"
			@white_pawn.update_row_column
			@game.piece_capture(@black_rook, "C6", "C5")
		end

		it "updates the captured piece's current position to ''" do
			expect(@white_pawn.current_position).to eql("")
		end

		it "moves the capturing piece to the finish square" do
			expect(@board.squares["C5"]).to eql(@black_rook)
		end

		it "clears the starting square" do
			expect(@board.squares["C6"]).to eql("")
		end

		it "updates the capturing piece's current position to the finish square" do
			expect(@black_rook.current_position).to eql("C5")
		end
	end
	
end