require_relative "../lib/game.rb"

describe Game do

	before(:each) do
		@player1 = Player.new "player1"
		@player2 = Player.new "player2"
		@game = Game.new [@player1, @player2]
	end

	context "when starting a new game" do

		context "given incorrect arguments" do

			it "raises a NoMethod error" do
				expect(Game.new ["player1", "player2"]).to raise_error(NoMethodError)
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
				expect(@game.players.select {|p| p.color == "white"}).to eql(@game.current_player)
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