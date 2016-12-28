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
			it "returns a message stating that there's no piece there" do
				expect(@game.play_turn("A4", "A5")).to eql("There's no piece there! Try again.")
			end
		end

		context "when moving piece isn't the same color as the current player" do
			it "returns a message stating that the piece the player is attempting to move doesn't belong to them" do
				expect(@game.play_turn("A2", "A3")).to eql("That's not your piece! Try again.")
			end
		end

		context "when attempting to move a piece to a square where a different piece of the same color already is" do
			it "returns a message stating that the player already has a piece on that square" do
				expect(@game.play_turn("A8", "A7")).to eql("You already have a piece there! Try again.")
			end
		end

		context "when move is illegal" do
			it "returns a message stating that the move is illegal" do
				expect(@game.play_turn("A7", "A4")).to eql("That move is illegal! Try again.")
			end
		end

	end
	
end