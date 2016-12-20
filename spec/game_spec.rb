require_relative "../lib/game.rb"

describe Game do

	before(:each) do
		@player1 = Player.new "player1"
		@player2 = Player.new "player2"
		@game = Game.new(@player1, @player2)
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

		context "when move is illegal" do

			context "because of piece's movement" do
				it "prints a message stating that the move is illegal and asking to try another move" do
					expect{@game.play_turn("B2", "B1")}.to output("That move is illegal! Try again.\n").to_stdout
				end

				it "returns false" do
					expect(@game.play_turn("B2", "B1")).to eql(false)
				end
			end

			context "because piece of same color occupies destination square" do
				it "prints a message stating a piece of the same color is already there and asks to try another move" do
					expect{@game.play_turn("A1", "A2")}.to output("You already have a piece there! Try again.\n").to_stdout
				end

				it "returns false" do
					expect(@game.play_turn("A1", "A2")).to eql(false)
				end
			end

			context "because player is a different color than the piece to be moved" do
				before(:each) do 
					current_player = @game.players.select {|p| p.color == "black"}
					@game.instance_variable_set(:@current_player, current_player.first)
				end

				it "prints a message stating that the piece to be moved is a different color than the current player's color" do
					expect{@game.play_turn("A2", "A3")}.to output("That's not your piece! Try again.\n").to_stdout
				end

				it "returns false" do
					expect(@game.play_turn("A2", "A3")).to eql(false)
				end
			end
		end

		context "when move is legal" do
			context "and the square is open" do
				
				before(:each) do
					@piece = @game.board.squares["A2"]
					@game.play_turn("A2", "A3")
				end

				it "changes the destination square to the piece that was moved" do
					expect(@game.board.squares["A3"]).to eql(@piece)
				end

				it "vacates the starting square" do
					expect(@game.board.squares["A2"]).to eql("")
				end

				it "prints the Algebraic notation of the move to the terminal" do
					expect{@game.play_turn("A3", "A4")}.to output("A4\n").to_stdout
				end
			end

			context "when the square is occupied by an opposing piece" do
			end
		end

	end

	describe ".game_over?" do

		context "when win or draw conditions haven't been met" do

			it "returns false" do
				expect(@game.game_over?).to eql(false)
			end

		end

		context "when black is in check mate" do

			it "returns true" do
				expect(@game.game_over?).to eql(true)
			end

		end

		context "when white is in check mate" do

			it "returns true" do
				expect(@game.game_over?).to eql(true)
			end

		end

		context "when a draw has been reached" do

			it "returns true" do
				expect(@game.game_over?).to eql(true)
			end

		end

	end
	
end