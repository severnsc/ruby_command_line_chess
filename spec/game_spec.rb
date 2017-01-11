require_relative "../lib/game.rb"
require_relative "./spec_helper.rb"

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
			current_player = @game.black_player
			@game.instance_variable_set(:@current_player, current_player)
		end

		context "when the move is legal and the player is not in check" do
			subject(:white_player) {@game.white_player}

			it "prints the algebraic notation of the move" do
				expect{@game.play_turn("A7", "A6")}.to output(/A6\n/).to_stdout
			end

			it "sets the piece's @moved? variable to true" do
				@game.play_turn("A7", "A6")
				expect(@board.squares["A6"].moved).to eql(true)
			end
		end

		context "when the move is legal and the player is now in check" do

		end

		context "when start square is empty" do
			it "prints a message stating that there's no piece there" do
				expect{@game.play_turn("A4", "A5")}.to output(/There's no piece there! Try again.\n/).to_stdout
			end
		end

		context "when moving piece isn't the same color as the current player" do
			it "prints a message stating that the piece the player is attempting to move doesn't belong to them" do
				expect{@game.play_turn("A2", "A3")}.to output(/That's not your piece! Try again.\n/).to_stdout
			end
		end

		context "when attempting to move a piece to a square where a different piece of the same color already is" do
			it "prints a message stating that the player already has a piece on that square" do
				expect{@game.play_turn("A8", "A7")}.to output(/You already have a piece there! Try again.\n/).to_stdout
			end
		end

		context "when a piece is in the way of the destination square" do
			before(:each) do
				@black_pawn = Pawn.new "black"
				@board.squares["A6"] = @black_pawn
				@black_pawn.current_position = "A6"
			end

			it "prints a message stating that there is a piece in the way" do
				expect{@game.play_turn("A7", "A5")}.to output(/There's a piece in the way! Try again.\n/).to_stdout
			end
		end

		context "when move is illegal" do
			it "prints a message stating that the move is illegal" do
				expect{@game.play_turn("A7", "A4")}.to output(/That move is illegal! Try again.\n/).to_stdout
			end
		end

		context "when performing a pawn capture" do
			before(:each) {@board.squares["B6"] = Pawn.new "white"}

			it "prints the algebraic notation of the capture" do
				expect{@game.play_turn("A7", "B6")}.to output(/AxB6\n/).to_stdout
			end

			it "updates the current player to the player of the opposing color" do
				@game.play_turn("A7", "B6")
				expect(@game.current_player).to eql(@game.white_player)
			end
		end

		context "when performing a pawn capture that leads to a promotion" do
			before(:each) do
				@black_pawn = @board.squares["A7"]
				@black_pawn.current_position = "A2"
				@board.squares["A2"] = @black_pawn
				@black_pawn.update_row_column
				@board.squares["A7"] = ""
			end

			it "prints the algebraic notation of the capture and the promotion" do
				expect{@game.play_turn("A2", "B1")}.to output(/AxB1\nB1Q\n/).to_stdout
			end
		end

		context "when moving a pawn to an open square" do

			context "but the open square is diagonal from the pawn and @en_passant is false" do
				it "prints a message stating that the move is illegal" do
					expect{@game.play_turn("A7", "B6")}.to output(/That move is illegal! Try again.\n/).to_stdout
				end 
			end

			it "prints the algebraic notation of the move" do
				expect{@game.play_turn("A7", "A6")}.to output(/A6\n/).to_stdout
			end

			it "changes the current player to the opponent" do
				@game.play_turn("A7", "A6")
				expect(@game.current_player).to eql(@game.white_player)
			end
		end

		context "when moving a pawn to an open square that would lead to a promotion" do
			before(:each) do
				@black_pawn = @board.squares["A7"]
				@black_pawn.current_position = "A2"
				@board.squares["A2"] = @black_pawn
				@board.squares["A7"] = ""
				@board.squares["A1"] = ""
			end

			it "prints the algebraic notation of the move and the promotion" do
				expect{@game.play_turn("A2", "A1")}.to output(/A1\nA1Q\n/).to_stdout
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
				expect{@game.play_turn("C6", "C5")}.to output(/RxC5\n/).to_stdout
			end

			it "updates the current player to the player of opposing color" do
				@game.play_turn("C6", "C5")
				expect(@game.current_player).to eql(@game.white_player)
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
				@board.squares["D1"] = ""
				@board.squares["D2"] = ""
				unless example.metadata[:skip_before]
					@game.play_turn("E7", "D6")
				end
			end

			it "prints a message saying the move is illegal because it puts current player's king in check", skip_before: true do
				expect{@game.play_turn("E7", "D6")}.to output(/That puts your king in check! Try again.\n/).to_stdout
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
				expect(@game.current_player).to eql(@game.black_player)
			end

		end

		context "when an open square move would put the current player's king in check" do
			before(:each) do |example|
				@black_king = @board.squares["E8"]
				@black_pawn = @board.squares["D7"]
				@white_queen = @board.squares["D1"]
				@white_queen.current_position = "C6"
				@board.squares["C6"] = @white_queen
				@board.squares["D1"] = ""
				unless example.metadata[:skip_before]
					@game.play_turn("D7", "D6")
				end
			end

			it "prints a message stating that you can't put your own king in check", skip_before: true do
				expect{@game.play_turn("D7", "D6")}.to output(/That puts your king in check! Try again.\n/).to_stdout
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

		context "when a piece capture would put the current player's king in check" do
			before(:each) do |example|
				@black_king = @board.squares["E8"]
				@black_knight = @board.squares["B8"]
				@white_queen = @board.squares["D1"]
				@white_pawn = @board.squares["D2"]
				@black_knight.current_position = "E7"
				@board.squares["E7"] = @black_knight
				@white_queen.current_position = "E6"
				@board.squares["E6"] = @white_queen
				@white_pawn.current_position = "F5"
				@board.squares["F5"] = @white_pawn
				@board.squares["B8"], @board.squares["D1"], @board.squares["D2"] = "", "", ""
				unless example.metadata[:skip_before]
					@game.play_turn("E7", "F5")
				end
			end

			it "prints a message stating that you can't put your own king in check", skip_before: true do
				expect{@game.play_turn("E7", "F5")}.to output(/That puts your king in check! Try again.\n/).to_stdout
			end

			it "replaces the captured piece on the board" do
				expect(@board.squares["F5"]).to  eql(@white_pawn)
			end

			it "updates the captured piece's current position to the original square" do
				expect(@white_pawn.current_position).to eql("F5")
			end

			it "replaces the moving piece to its original square" do
				expect(@board.squares["E7"]).to eql(@black_knight)
			end

			it "updates the moving piece's current position to its original position" do
				expect(@black_knight.current_position).to eql("E7")
			end

			it "resets @king_in_check to false" do
				expect(@game.king_in_check).to eql(false)
			end
		end

		context "when a move by the white player would put the black player in checkmate" do
			before(:each) do
				@current_player = @game.white_player
				@game.instance_variable_set(:@current_player, @current_player)
				@white_bishop = @board.squares["C1"]
				@board.squares["C1"] = ""
				white_rook = @board.squares["A1"]
				white_queen = @board.squares["D1"]
				@board.squares["D1"] = ""
				@board.squares["D7"] = @white_bishop
				@white_bishop.current_position = "D7"
				@board.squares["G8"] = white_queen
				white_queen.current_position = "G8"
				@board.squares["F6"] = white_rook
				white_rook.current_position = "F6"
				@board.squares["E7"] = ""
				@board.squares["F8"] = ""
			end

			it "outputs a message saying that the white player has won" do
				expect{@game.play_turn("F6", "F7")}.to output(/RxF7\nGame over! #{@current_player.name} wins!\n/).to_stdout
			end
		end

		context "when a move by the black player would put the white player in checkmate" do
			before(:each) do
				@current_player = @game.players.select {|p| p.color=="black"}[0]
				black_bishop = @board.squares["C8"]
				@board.squares["C8"] = ""
				black_rook = @board.squares["A8"]
				black_queen = @board.squares["D8"]
				@board.squares["F2"] = black_bishop
				black_bishop.current_position = "F2"
				@board.squares["D3"] = black_rook
				black_rook.current_position = "D3"
				@board.squares["C1"] = black_queen
				black_queen.current_position = "C1"
				@board.squares["D1"] = ""
				@board.squares["E2"] = ""
			end

			it "outputs a message saying that the black player has won" do
				expect{@game.play_turn("D3", "D2")}.to output(/RxD2\nGame over! #{@current_player.name} wins!\n/).to_stdout
			end
		end

		context "when performing castles with the white king" do
			before(:each) do
				current_player = @game.players.select {|p| p.color=="white"}
				@game.instance_variable_set(:@current_player, current_player[0])
			end

			context "queenside castle" do
				before(:example) {@board.squares["B1"], @board.squares["C1"], @board.squares["D1"] = "", "", ""}

				it "outputs the algebraic notation of the castle" do
					expect{@game.play_turn("A1", "E1")}.to output(/0-0-0\n/).to_stdout
				end

				context "and the king would end in check" do
					before(:example) do
						@board.squares["C2"] = @board.squares["A8"]
						@board.squares["C2"].current_position = "C2"
						@board.squares["C2"].update_row_column
					end

					it "prints a message saying the king can't end in check" do
						expect{@game.play_turn("A1", "E1")}.to output(/Illegal castle! King can't end in check.\n/).to_stdout
					end
				end

				context "and the king would pass through check" do
					before(:example) do
						@board.squares["D2"] = @board.squares["A8"]
						@board.squares["D2"].current_position = "D2"
						@board.squares["D2"].update_row_column
					end

					it "prints a message saying that the king can't move throguh check" do
						expect{@game.play_turn("A1", "E1")}.to output(/Illegal castle! King can't move through check.\n/).to_stdout
					end
				end
			end

			context "kingside castle" do
				before(:example) {@board.squares["F1"], @board.squares["G1"] = "", ""}

				it "outputs the algebraic notation of the castle" do
					expect{@game.play_turn("H1", "E1")}.to output(/0-0\n/).to_stdout
				end

				context "and the king would end in check" do
					before(:example) do
						@board.squares["G2"] = @board.squares["A8"]
						@board.squares["G2"].current_position = "G2"
						@board.squares["G2"].update_row_column
					end

					it "prints a message saying that the king can't end in check" do
						expect{@game.play_turn("H1", "E1")}.to output(/Illegal castle! King can't end in check.\n/).to_stdout
					end
				end

				context "and the king would pass through check" do
					before(:example) do
						@board.squares["F2"] = @board.squares["A8"]
						@board.squares["F2"].current_position = "F2"
						@board.squares["F2"].update_row_column
					end

					it "prints a message saying that the king can't move through check" do
						expect{@game.play_turn("H1", "E1")}.to output(/Illegal castle! King can't move through check.\n/).to_stdout
					end
				end
			end
		end

		context "when performing castles with the black king" do
			context "queenside castle" do
				before(:example) {@board.squares["B8"], @board.squares["C8"], @board.squares["D8"] = "", "", ""}

				it "prints the algebraic notation of the castle" do
					expect{@game.play_turn("A8", "E8")}.to output(/0-0-0\n/).to_stdout
				end

				context "and the king would end in check" do
					before(:example) do
						@board.squares["C7"] = @board.squares["A1"]
						@board.squares["C7"].current_position = "C7"
						@board.squares["C7"].update_row_column
					end

					it "prints a message saying that the king can't end in check" do
						expect{@game.play_turn("A8", "E8")}.to output(/Illegal castle! King can't end in check.\n/).to_stdout
					end
				end

				context "and the king would pass through check" do
					before(:example) do
						@board.squares["D7"] = @board.squares["A1"]
						@board.squares["D7"].current_position = "D7"
						@board.squares["D7"].update_row_column
					end

					it "prints a message saying that the king can't move through check" do
						expect{@game.play_turn("A8", "E8")}.to output(/Illegal castle! King can't move through check.\n/).to_stdout
					end
				end
			end

			context "kingside castle" do
				before(:example) {@board.squares["F8"], @board.squares["G8"] = "", ""}

				it "prints the algebraic notation of the castle" do
					expect{@game.play_turn("H8", "E8")}.to output(/0-0\n/).to_stdout
				end

				context "and the king would end in check" do
					before(:example) do
						@board.squares["G7"] = @board.squares["A1"]
						@board.squares["G7"].current_position = "G7"
						@board.squares["G7"].update_row_column
					end

					it "prints a message saying that the king can't end in check" do
						expect{@game.play_turn("H8", "E8")}.to output(/Illegal castle! King can't end in check.\n/).to_stdout
					end
				end

				context "and the queen would end in check" do
					before(:example) do
						@board.squares["F7"] = @board.squares["A1"]
						@board.squares["F7"].current_position = "F7"
						@board.squares["F7"].update_row_column
					end

					it "prints a message saying that the king can't pass through check" do
						expect{@game.play_turn("H8", "E8")}.to output(/Illegal castle! King can't move through check.\n/).to_stdout
					end
				end
			end
		end
	end

	describe ".players" do
		it "returns an array containing player1 and player2" do
			expect(@game.players).to eql([@player1, @player2])
		end
	end

	describe ".offer_draw" do
		context "when player 1 offers the draw" do
			before(:example) {@game.instance_variable_set(:@current_player, @player1)}

			it "prints a message saying that player 1 has offered a draw and asks player 2 whether s/he accepts" do
				expect{@game.offer_draw}.to output("#{@player2.name}, #{@player1.name} has offered a draw. Do you accept? Type 'Y' for yes or 'N' for no.\nDraw rejected.\n").to_stdout
			end
		end

		context "when player 2 offers the draw" do
			before(:example) {@game.instance_variable_set(:@current_player, @player2)}

			it "prints a message saying that player 2 has offered a draw and asks player 2 whether s/he accepts" do
				expect{@game.offer_draw}.to output("#{@player1.name}, #{@player2.name} has offered a draw. Do you accept? Type 'Y' for yes or 'N' for no.\nDraw rejected.\n").to_stdout
			end
		end
	end
end