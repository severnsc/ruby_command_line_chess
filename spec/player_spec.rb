require_relative "../lib/player.rb"
require_relative "./spec_helper.rb"

describe Player do

	subject(:player) {Player.new "player"}

	describe ".name" do
		it "should return the player's name" do
			expect(player.name).to eql("player")
		end
	end

	describe ".name=" do
		it "should allow you to change the player name" do
			player.name = "player2"
			expect(player.name).to eql("player2")
		end

		it "should puts the new name to the screen" do
			expect(player.name = "player2").to eql("player2")
		end
	end

	before do
		color = "white"
		player.instance_variable_set(:@color, color)
	end

	describe ".color" do
		it "should puts the player's color" do
			expect(player.color).to eql("white")
		end
	end

end