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

		context "when a piece is in the way of the destination square" do
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

			it "changes the current player to the opponent" do
				@game.play_turn("A7", "A6")
				expect(@game.current_player).to eql(@game.players.select {|p| p.color=="white"}[0])
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

		context "when a pawn capture would put the current player's King in check" do
			before(:each) do |example|
				@black_pawn = @board.squares["E7"]
				@black_king = @board.squares["E8"]
				@white_queen = @board.squares["D1"]
				@white_pawn = @board.squares["D2"]
				@white_pawn.current_position = "D6"
				@board.squares["D6"] = @white_pawn
				@white_queen.current_position = "E6"
				@board.squares["E6"] = @white_queen
				unless example.metadata[:skip_before]
					@game.play_turn("E7", "D6")
				end
			end

			it "prints a message saying the move is illegal because it puts current player's king in check", skip_before: true do
				expect{@game.play_turn("E7", "D6")}.to output("ExD6\nThat puts your king in check! Try again.\n").to_stdout
			end

			it "replaces the captured piece on the board" do
				expect(@board.squares["D6"]).to eql(@white_pawn)
			end

			it "resets the captured piece's current position to its original square" do
				expect(@white_pawn.current_position).to eql("D6")
			end

			it "moves the moving piece back to its original square" do
				expect(@board.squares["E7"]).to eql(@black_pawn)
			end

			it "updates the moving piece's current position to its original square" do
				expect(@black_pawn.current_position).to eql("E7")
			end

			it "resets @king_in_check to false" do
				expect(@game.king_in_check).to eql(false)
			end

			it "leaves the current player the same" do
				expect(@game.current_player).to eql(@game.players.select {|p| p.color=="black"}[0])
			end

		end

		context "when an open square move would put the current player's king in check" do
			before(:each) do |example|
				@black_king = @board.squares["E8"]
				@black_pawn = @board.squares["D7"]
				@white_queen = @board.squares["D1"]
				@white_queen.current_position = "C6"
				@board.squares["C6"] = @white_queen
				unless example.metadata[:skip_before]
					@game.play_turn("D7", "D6")
				end
			end

			it "prints a message stating that you can't put your own king in check", skip_before: true do
				expect{@game.play_turn("D7", "D6")}.to output("D6\nThat puts your king in check! Try again.\n").to_stdout
			end

			it "resets the moving piece back to the start square" do
				expect(@board.squares["D7"]).to eql(@black_pawn)
			end

			it "resets the moving piece's current position" do
				expect(@black_pawn.current_position).to eql("D7")
			end

			it "empties the destination square" do
				expect(@board.squares["D6"]).to eql("")
			end

			it "resets @king_in_check to false" do
				expect(@game.king_in_check).to eql(false)
			end

		end

	end

	describe ".piece_in_the_way?" do
		
		context "when moving a black pawn from the opening position with a piece in the way" do
			before(:each) do
				@black_pawn = @board.squares["A7"]
				@white_pawn = Pawn.new "white"
				@board.squares["A6"] = @white_pawn
			end

			context "when moving the pawn 1 square from the opening posiiton" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@black_pawn, "A7", "A6")).to eql(true)
				end
			end

			context "when moving the pawn 2 squares from the opening position" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@black_pawn, "A7", "A5")).to eql(true)
				end
			end
		end

		context "when moving a white pawn from the opening position with a piece in the way" do
			before(:each) do
				@white_pawn = @board.squares["A2"]
				@black_pawn = Pawn.new "black"
				@board.squares["A3"] = @black_pawn
			end

			context "when moving 1 square from opening position" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@white_pawn, "A2", "A3")).to eql(true)
				end
			end

			context "when moving 2 squares from the opening position" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@white_pawn, "A2", "A4")).to eql(true)
				end
			end
		end

		context "when moving a pawn after the opening position with a piece in the way" do
			before(:each) do
				@black_pawn = Pawn.new "black"
				@board.squares["A5"] = @black_pawn
				@black_pawn.current_position = "A4"
				@black_pawn.update_row_column
				@white_pawn = Pawn.new "white"
				@board.squares["A4"] = @white_pawn
				@white_pawn.current_position = "A4"
				@white_pawn.update_row_column
			end

			context "and the pawn is black" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@black_pawn, "A5", "A4")).to eql(true)
				end
			end

			context "and the pawn is white" do
				it "returns true" do
					expect(@game.piece_in_the_way?(@white_pawn, "A4", "A5")).to eql(true)
				end
			end
		end

		context "when moving a rook with a piece in the way" do
			subject(:black_rook) {@board.squares["A8"]}
			subject(:white_rook) {@board.squares["A1"]}

			context "and the rook is moving vertically" do
				context "down the board" do
					it "returns true" do
						expect(@game.piece_in_the_way?(black_rook, "A8", "A6")).to eql(true)
					end
				end

				context "up the board" do
					it "returns true" do
						expect(@game.piece_in_the_way?(white_rook, "A1", "A3")).to eql(true)
					end
				end
			end

			context "and the rook is moving horizontally" do
				context "to the right" do
					it "returns true" do
						expect(@game.piece_in_the_way?(black_rook, "A8", "C8")).to eql(true)
					end
				end

				context "to the left" do
					it "returns true" do
						expect(@game.piece_in_the_way?(white_rook, "A1", "C1")).to eql(true)
					end
				end
			end

		end 

		context "when a bishop is moving with a piece in the way" do
			context "and the bishop is moving on black squares" do
				before(:each) do
					@black_bishop = Bishop.new "black"
					@board.squares["C3"] = @black_bishop
					@black_bishop.current_position = "C3"
					@black_bishop.update_row_column
				end

				context "and increasing row and column" do
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "C3", "H8")).to eql(true)
					end
				end

				context "and decreasing row and column" do
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "C3", "A1")).to eql(true)
					end
				end

				context "and increasing row and decreasing column" do
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "C3", "E1"))
					end
				end

				context "and decreasing row and increasing column" do
					before(:example) do
						@white_pawn = Pawn.new "white"
						@board.squares["B4"] = @white_pawn
					end

					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "C3", "A5")).to eql(true)
					end
				end
			end

			context "and the bishop is moving on white squares" do
				before(:each) do
					@black_bishop = Bishop.new "black"
					@board.squares["D3"] = @black_bishop
					@black_bishop.current_position = "D3"
					@black_bishop.update_row_column
				end

				context "and increasing row and column" do
					before(:example) do
						@white_pawn = Pawn.new "white"
						@board.squares["G6"] = @white_pawn
					end
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "D3", "H7")).to eql(true)
					end
				end

				context "and decreasing row and column" do
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "D3", "B1")).to eql(true)
					end
				end

				context "and increasing row and decreasing column" do
					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "D3", "F1")).to eql(true)
					end
				end

				context "and decreasing row and increasing column" do
					before(:example) do
						@white_pawn = Pawn.new "white"
						@board.squares["B5"] = @white_pawn
					end

					it "returns true" do
						expect(@game.piece_in_the_way?(@black_bishop, "D3", "A6")).to eql(true)
					end
				end
			end
		end

		context "when moving a Queen with a piece in the way" do
			subject(:queen) {Queen.new "black"}
			subject(:pawn) {Pawn.new "white"}

			before(:each) {@board.squares["D4"] = queen}

			context "and the queen is moving vertically" do
				context "up the board" do
					before(:example) {@board.squares["D5"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "D6")).to eql(true)
					end
				end

				context "down the board" do
					before(:example) {@board.squares["D3"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "D2")).to eql(true)
					end
				end
			end

			context "and the queen is moving horizontally" do
				context "to the right" do
					before(:example) {@board.squares["E4"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "F4")).to eql(true)
					end
				end

				context "to the left" do
					before(:example) {@board.squares["C4"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "B4")).to eql(true)
					end
				end
			end

			context "and the queen is moving diagonally" do
				context "increasing row and column" do
					before(:example) {@board.squares["E5"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "F6")).to eql(true)
					end
				end

				context "decreasing row, increasing column" do
					before(:example) {@board.squares["E3"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "F2")).to eql(true)
					end
				end

				context "decreasing row and column" do
					before(:example) {@board.squares["C3"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "B2")).to eql(true)
					end
				end

				context "increasing row, decreasing column" do
					before(:example) {@board.squares["C5"] = pawn}

					it "returns true" do
						expect(@game.piece_in_the_way?(queen, "D4", "B6")).to eql(true)
					end
				end
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

	describe ".king_in_check?" do
		subject(:king) {@board.kings.select {|k| k.color=="black"}[0]}
		subject(:queen) {Queen.new "white"}

		context "when King is at E8" do
			before(:each) do
				@board.squares["E8"] = king
				king.current_position = "E8"
			end

			context "and attacking Queen at E7" do
				before(:example) do
					@board.squares["E7"] = queen
					queen.current_position = "E7"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking Queen at D7" do
				before(:example) do
					@board.squares["D7"] = queen
					queen.current_position = "D7"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen at F7" do
				before(:example) do
					@board.squares["F7"] = queen
					queen.current_position = "F7"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen at D8" do
				before(:example) do
					@board.squares["D8"] = queen
					queen.current_position = "D8"
					@game.king_in_check?
				end

				it "sets the @game.king_in_check to black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen at F8" do
				before(:example) do
					@board.squares["E8"] = queen
					queen.current_position = "E8"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen is at E6 with pawn in the way" do
				before(:example) do
					@board.squares["E6"] = queen
					queen.current_position = "E6"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at D6 with a pawn in the way" do
				before(:example) do
					@board.squares["D6"] = queen
					queen.current_position = "D6"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at F6 with a pawn in the way" do
				before(:example) do 
					@board.squares["F6"] = queen
					queen.current_position = "F6"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at C8 with a Queen in the way" do
				before(:example) do
					@board.squares["C8"] = queen
					queen.current_position = "C8"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at G8 with a bishop in the way" do
				before(:example) do
					@board.squares["G8"] = queen
					queen.current_position = "G8"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end
		end

		context "when King is at E7" do
			before(:each) do
				@board.squares["E7"] = king
				king.current_position = "E7"
			end

			context "and attacking queen is at E8" do
				before(:example) do
					@board.squares["E8"] = queen
					queen.current_position = "E8"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen is at D8" do
				before(:example) do
					@board.squares["D8"] = queen
					queen.current_position = "D8"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end

			context "and attacking queen is at F8" do
				before(:example) do
					@board.squares["F8"] = queen
					queen.current_position = "F8"
					@game.king_in_check?
				end

				it "sets @game.king_in_check to the black King" do
					expect(@game.king_in_check).to eql(king)
				end
			end
		end

		context "when king is at E5 with a pawn blocker" do
			subject(:blocking_pawn) {@board.pawns.select {|p| p.color=="black"}[0]}
			
			before(:each) do
				@board.squares["E5"] = king
				king.current_position = "E5"
			end

			context "and attacking queen is at E7 with black pawn at E6" do
				before(:example) do
					@board.squares["E6"] = blocking_pawn
					blocking_pawn.current_position = "E6"
					@board.squares["E7"] = queen
					queen.current_position = "E7"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at C7 with black pawn at D6" do
				before(:example) do
					@board.squares["D6"] = blocking_pawn
					blocking_pawn.current_position = "D6"
					@board.squares["C7"] = queen
					queen.current_position = "C7"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end

			context "and attacking queen is at G7 with a black pawn at F6" do
				before(:example) do
					@board.squares["F6"] = blocking_pawn
					blocking_pawn.current_position = "F6"
					@board.squares["G7"] = queen
					queen.current_position = "G7"
					@game.king_in_check?
				end

				it "leaves @game.king_in_check as false" do
					expect(@game.king_in_check).to eql(false)
				end
			end
		end
	end
	
end