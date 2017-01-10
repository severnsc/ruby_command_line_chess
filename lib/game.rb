require_relative "./player.rb"
require_relative "./pieces.rb"
require_relative "./board.rb"
require 'yaml'

class Game
	attr_reader :board, :current_player, :king_in_check, :checkmate, :en_passant

	def initialize(player1, player2)
		player1.is_a?(Player) ? @player1 = player1 : raise(TypeError)
		player2.is_a?(Player) ? @player2 = player2 : raise(TypeError)
		@board = Board.new
		random = rand(0..1)
		if random == 0
			@player1.color = "white"
			@player2.color = "black"
		else
			@player1.color = "black"
			@player2.color = "white"
		end
		@player1.color == "white" ? @current_player = @player1 : @current_player = @player2
		@king_in_check = false
		@checkmate = false
		@en_passant = false
	end

	def players
		[@player1, @player2]
	end

	def play_turn(start, finish)
		moving_piece = @board.squares[start]
		if moving_piece == ""
			puts "There's no piece there! Try again."
		elsif moving_piece.color != @current_player.color
			puts "That's not your piece! Try again."
		elsif @board.squares[finish] != "" && @board.squares[finish].color == moving_piece.color
			if moving_piece.is_a?(Rook) && @board.squares[finish].is_a?(King)
				if piece_in_the_way?(moving_piece, start, finish)
					puts "There's a piece in the way! Try again."
				else
					castle(moving_piece, @board.squares[finish])
					@current_player = players.select {|p| p != @current_player}[0]
				end
			elsif moving_piece.is_a?(King) && @board.squares[finish].is_a?(Rook)
				if piece_in_the_way?(moving_piece, start, finish)
					puts "There's a piece in the way! Try again."
				else
					castle(@board.squares[finish], moving_piece)
					@current_player = players.select {|p| p != @current_player}[0]
				end	
			else
				puts "You already have a piece there! Try again."
			end
		elsif moving_piece.is_a?(Pawn) && pawn_legal_capture_distance?(moving_piece, finish) && @board.squares[finish] != ""
			captured_piece = @board.squares[finish]
			pawn_capture(moving_piece, start, finish)
			if moving_piece.moved == false
				moving_piece.moved = true
			end
			pawn_promotion(moving_piece) if moving_piece.color == "white" && finish.split('').last == "8"
			pawn_promotion(moving_piece) if moving_piece.color == "black" && finish.split('').last == "1"
			king_in_check?
			if @king_in_check && @king_in_check.color == @current_player.color
				@board.squares[finish] = captured_piece
				captured_piece.current_position = finish
				moving_piece.current_position = start
				@board.squares[start] = moving_piece
				@king_in_check = false
				puts "That puts your king in check! Try again."
			elsif @king_in_check
				check_mate?
				if @checkmate
					puts "Game over! #{@current_player.name} wins!"
				else
					@current_player = players.select {|p| p != @current_player}[0]
					puts "#{@current_player.name}, you are in check!"
				end
			else
				@current_player = players.select {|p| p != @current_player}[0]
			end
		elsif @en_passant && moving_piece.is_a?(Pawn) && pawn_legal_capture_distance?(moving_piece, finish)
			captured_pawn = @en_passant
			en_passant_pawn_capture(moving_piece, start, finish)
			moving_piece.moved = true if moving_piece.moved == false
			king_in_check?
			if @king_in_check && @king_in_check.color == @current_player.color
				@board.squares[finish] = ""
				captured_pawn.current_position = @en_passant.current_position
				moving_piece.current_position = start
				@board.squares[start] = moving_piece
				@board.squares[captured_pawn.current_position] = captured_pawn
				@king_in_check = false
				puts "That puts your king in check! Try again."
			elsif @king_in_check
				check_mate?
				if @checkmate
					puts "Game over! #{@current_player.name} wins!"
				else
					@current_player = players.select {|p| p != @current_player}[0]
					puts "#{@current_player.name}, you are in check!"
				end
			else
				@current_player = players.select {|p| p != @current_player}[0]
			end
		elsif !moving_piece.is_move_legal?(finish)
			puts "That move is illegal! Try again."
		elsif piece_in_the_way?(moving_piece, start, finish)
			puts "There's a piece in the way! Try again."
		elsif @board.squares[finish] == ""
			open_square_move(moving_piece, start, finish)
			moving_piece.moved = true if moving_piece.moved == false
			pawn_promotion(moving_piece) if moving_piece.is_a?(Pawn) && moving_piece.color == "white" && finish.split('').last == "8"
			pawn_promotion(moving_piece) if moving_piece.is_a?(Pawn) && moving_piece.color == "black" && finish.split('').last == "1"
			king_in_check?
			if @king_in_check && @king_in_check.color == @current_player.color
				@board.squares[start] = moving_piece
				moving_piece.current_position = start
				@board.squares[finish] = ""
				@king_in_check = false
				puts "That puts your king in check! Try again."
			elsif @king_in_check
				check_mate?
				if @checkmate
					puts "Game over! #{@current_player.name} wins!"
				else
					@current_player = players.select {|p| p != @current_player}[0]
					puts "#{@current_player.name}, you are in check!"
				end
			else
				@current_player = players.select {|p| p != @current_player}[0]
			end
		elsif @board.squares[finish] != ""
			captured_piece = @board.squares[finish]
			piece_capture(moving_piece, start, finish)
			moving_piece.moved = true if moving_piece.moved == false
			king_in_check?
			if @king_in_check && @king_in_check.color == @current_player.color
				@board.squares[finish] = captured_piece
				captured_piece.current_position = finish
				moving_piece.current_position = start
				@board.squares[start] = moving_piece
				@king_in_check = false
				puts "That puts your king in check! Try again."
			elsif @king_in_check
				check_mate?
				if @checkmate
					puts "Game over! #{@current_player.name} wins!"
				else
					@current_player = players.select {|p| p != @current_player}[0]
					puts "#{@current_player.name}, you are in check!"
				end
			else
				@current_player = players.select {|p| p != @current_player}[0]
			end
		end
		en_passant?(moving_piece, start, finish) unless moving_piece == ""
		@board.display
	end

	def piece_in_the_way?(piece, start, finish)
		in_the_way = true
		start_col = start.split("").first
		finish_col = finish.split("").first
		start_row = start.split("").last.to_i
		finish_row = finish.split("").last.to_i
		if piece.is_a? Pawn
			if piece.color == "black" && start_row == 7 && @board.squares[start_col + "6"] == ""
				in_the_way = false
			elsif piece.color == "white" && start_row == 2 && @board.squares[start_col + "3"] == ""
				in_the_way = false
			elsif piece.color == "black" && @board.squares[start_col + (start_row - 1).to_s] == ""
				in_the_way = false
			elsif piece.color == "white" && @board.squares[start_col + (start_row + 1).to_s] == ""
				in_the_way = false
			end
		elsif piece.is_a? Rook
			#moving horizontally
			if start_col != finish_col
				#moving right
				if start_col < finish_col
					between_cols = @board.x_axis[(@board.x_axis.index(start_col)+1)...@board.x_axis.index(finish_col)]
					between_squares = []
					between_cols.each {|col| between_squares.push(col + piece.current_row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				#moving left
				else
					between_cols = @board.x_axis[(@board.x_axis.index(finish_col)+1)...@board.x_axis.index(start_col)]
					between_squares = []
					between_cols.each {|col| between_squares.push(col + piece.current_row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				end
			#moving vertically
			elsif start_row != finish_row
				#moving up the board
				if start_row < finish_row
					between_rows = @board.y_axis[(start_row)...(finish_row-1)]
					between_squares = []
					between_rows.each {|row| between_squares.push(start_col + row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				#moving down the board
				else
					between_rows = @board.y_axis[(finish_row)...(start_row-1)]
					between_squares = []
					between_rows.each {|row| between_squares.push(start_col + row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				end
			end
		elsif piece.is_a? Knight
			in_the_way = false
		elsif piece.is_a? Bishop
			#increasing column and row
			if start_col < finish_col && start_row < finish_row
				between_cols = @board.x_axis[@board.x_axis.index(start_col)+1...@board.x_axis.index(finish_col)]
				between_rows = @board.y_axis[start_row...(finish_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#increasing column, decreasing row
			elsif start_col < finish_col && start_row > finish_row
				between_cols = @board.x_axis[@board.x_axis.index(start_col)+1...@board.x_axis.index(finish_col)]
				between_rows = @board.y_axis[finish_row...(start_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows.reverse[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#decreasing column and row
			elsif start_col > finish_col && start_row > finish_row
				between_cols = @board.x_axis[@board.x_axis.index(finish_col)+1...@board.x_axis.index(start_col)]
				between_rows = @board.y_axis[finish_row...(start_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#decresing column, increasing row
			else
				between_cols = @board.x_axis[@board.x_axis.index(finish_col)+1...@board.x_axis.index(start_col)]
				between_rows = @board.y_axis[start_row...(finish_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows.reverse[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			end
		elsif piece.is_a?(Queen)
			#moving horizontally
			if start_col != finish_col && start_row == finish_row
				#moving right
				if start_col < finish_col
					between_cols = @board.x_axis[(@board.x_axis.index(start_col)+1)...@board.x_axis.index(finish_col)]
					between_squares = []
					between_cols.each {|col| between_squares.push(col + piece.current_row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				#moving left
				else
					between_cols = @board.x_axis[(@board.x_axis.index(finish_col)+1)...@board.x_axis.index(start_col)]
					between_squares = []
					between_cols.each {|col| between_squares.push(col + piece.current_row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				end
			#moving vertically
			elsif start_row != finish_row && start_col == finish_col
				#moving up the board
				if start_row < finish_row
					between_rows = @board.y_axis[(start_row)...(finish_row-1)]
					between_squares = []
					between_rows.each {|row| between_squares.push(start_col + row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				#moving down the board
				else
					between_rows = @board.y_axis[(finish_row)...(start_row-1)]
					between_squares = []
					between_rows.each {|row| between_squares.push(start_col + row.to_s)}
					in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
				end
			#increasing column and row
			elsif start_col < finish_col && start_row < finish_row
				between_cols = @board.x_axis[@board.x_axis.index(start_col)+1...@board.x_axis.index(finish_col)]
				between_rows = @board.y_axis[start_row...(finish_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#increasing column, decreasing row
			elsif start_col < finish_col && start_row > finish_row
				between_cols = @board.x_axis[@board.x_axis.index(start_col)+1...@board.x_axis.index(finish_col)]
				between_rows = @board.y_axis[finish_row...(start_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows.reverse[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#decreasing column and row
			elsif start_col > finish_col && start_row > finish_row
				between_cols = @board.x_axis[@board.x_axis.index(finish_col)+1...@board.x_axis.index(start_col)]
				between_rows = @board.y_axis[finish_row...(start_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			#decresing column, increasing row
			else
				between_cols = @board.x_axis[@board.x_axis.index(finish_col)+1...@board.x_axis.index(start_col)]
				between_rows = @board.y_axis[start_row...(finish_row-1)]
				between_squares = []
				between_cols.each_with_index {|col, index| between_squares.push(col + between_rows.reverse[index].to_s)}
				in_the_way = false if between_squares.all? {|sq| @board.squares[sq] == ""}
			end
		else
			in_the_way = false
		end
		in_the_way
	end

	def pawn_legal_capture_distance?(pawn, square)
		legal = false
		landing_distance = []
		landing_distance.push(@board.x_axis.index(square.split('').first) - @board.x_axis.index(pawn.current_column))
		landing_distance.push(square.split('').last.to_i - pawn.current_row)
		if pawn.color == "white"
			legal_distances = [[-1, 1], [1,1]]
			legal = true if legal_distances.include?(landing_distance)
		else
			legal_distances = [[-1, -1], [1, -1]]
			legal = true if legal_distances.include?(landing_distance)
		end
		legal
	end

	def pawn_capture(pawn, start, finish)
		@board.squares[finish].current_position = ""
		@board.squares[finish] = pawn
		@board.squares[start] = ""
		pawn.current_position = finish
		puts "#{start.split('').first}x" + finish
	end

	def open_square_move(piece, start, finish)
		@board.squares[finish] = piece
		@board.squares[start] = ""
		piece.current_position = finish
		if piece.is_a? Pawn
			puts finish
		elsif piece.is_a? Rook
			puts "R" + finish
		elsif piece.is_a? Knight
			puts "N" + finish
		elsif piece.is_a? Bishop
			puts "B" + finish
		elsif piece.is_a? Queen
			puts "Q" + finish
		else
			puts "K" + finish
		end
	end

	def piece_capture(piece, start, finish)
		captured_piece = @board.squares[finish]
		captured_piece.current_position = ""
		@board.squares[finish] = piece
		@board.squares[start] = ""
		piece.current_position = finish
		if piece.is_a? Rook
			puts "Rx" + finish
		elsif piece.is_a? Knight
			puts "Nx" + finish
		elsif piece.is_a? Bishop
			puts "Bx" + finish
		elsif piece.is_a? Queen
			puts "Qx" + finish
		else
			puts "Kx" + finish
		end
	end

	def king_in_check?
		white_king = @board.kings.select {|k| k.color == "white"}[0]
		black_king = @board.kings.select {|k| k.color == "black"}[0]
		@board.squares.any? {|sq, piece| piece != "" && piece.color == "black" && piece.is_move_legal?(white_king.current_position) && !piece_in_the_way?(piece, sq, white_king.current_position)} ? @king_in_check = white_king : @king_in_check = false
		return @king_in_check if @king_in_check
		@board.squares.any? {|sq, piece| piece != "" && piece.color == "white" && piece.is_move_legal?(black_king.current_position) && !piece_in_the_way?(piece, sq, black_king.current_position)} ? @king_in_check = black_king : @king_in_check = false
		return @king_in_check if @king_in_check
	end

	def legal_moves(piece)
		if piece.is_a? Pawn
			legal_moves = @board.squares.select {|sq, p| (piece.is_move_legal?(sq) && !piece_in_the_way?(piece, piece.current_position, sq) && @board.squares[sq] == "" ) || (@board.squares[sq] != "" && pawn_legal_capture_distance?(piece, sq))}
		else
			legal_moves = @board.squares.select {|sq, p| (piece.is_move_legal?(sq) && !piece_in_the_way?(piece, piece.current_position, sq) && @board.squares[sq] == "") || (@board.squares[sq] != "" && @board.squares[sq].color != piece.color && piece.is_move_legal?(sq) && !piece_in_the_way?(piece, piece.current_position, sq))}
		end
		legal_moves.keys
	end

	def en_passant?(piece, start, finish)
		@en_passant = false
		if piece.color == "white" && start.split('').last == "2" && finish.split('').last == "4"
			passed_square = start.split('').first + "3"
			black_pawns = @board.pawns.select {|p| p.color=="black"}
			@en_passant = piece if black_pawns.any? {|p| pawn_legal_capture_distance?(p, passed_square)}
		elsif piece.color == "black" && start.split('').last == "7" && finish.split('').last == "5"
			passed_square = start.split('').first + "6"
			white_pawns = @board.pawns.select {|p| p.color=="white"}
			@en_passant = piece if white_pawns.any? {|p| pawn_legal_capture_distance?(p, passed_square)}
		end
	end

	def en_passant_pawn_capture(pawn, start, finish)
		en_passant_square = @en_passant.current_position
		@board.squares[en_passant_square].current_position = ""
		@board.squares[finish] = pawn
		@board.squares[start] = ""
		@board.squares[en_passant_square] = ""
		pawn.current_position = finish
		puts "#{start.split('').first}x" + finish + "e.p."
	end

	def pawn_promotion pawn
		promote_square = pawn.current_position
		pawn.current_position = ""
		new_queen = Queen.new pawn.color
		@board.queens.push(new_queen)
		@board.squares[promote_square] = new_queen
		new_queen.current_position = promote_square
		puts promote_square + "Q"
	end

	def castle(rook, king)
		unless rook.moved || king.moved
			black_pieces = @board.squares.values.select {|p| p != "" && p.color=="black"}
			white_pieces = @board.squares.values.select {|p| p != "" && p.color=="white"}
			if rook.color == "white"
				if rook.current_position == "A1" && black_pieces.none? {|p| legal_moves(p).include?("D1") || legal_moves(p).include?("C1")}
					rook.current_position = "D1"
					king.current_position = "C1"
					@board.squares["D1"] = rook
					@board.squares["C1"] = king
					@board.squares["A1"] = ""
					@board.squares["E1"] = ""
					puts "0-0-0"
				elsif rook.current_position == "H1" && black_pieces.none? {|p| legal_moves(p).include?("F1") || legal_moves(p).include?("G1")}
					rook.current_position = "F1"
					king.current_position = "G1"
					@board.squares["F1"] = rook
					@board.squares["G1"] = king
					@board.squares["E1"] = ""
					@board.squares["H1"] = ""
					puts "0-0"
				elsif black_pieces.any? {|p| legal_moves(p).include?("D1") || legal_moves(p).include?("F1")}
					puts "Illegal castle! King can't move through check."
				elsif black_pieces.any? {|p| legal_moves(p).include?("C1") || legal_moves(p).include?("G1")}
					puts "Illegal castle! King can't end in check."
				end
			else
				if rook.current_position == "A8" && white_pieces.none? {|p| legal_moves(p).include?("D8") || legal_moves(p).include?("C8")}
					rook.current_position = "D8"
					king.current_position = "C8"
					@board.squares["D8"] = rook
					@board.squares["C8"] = king
					@board.squares["A8"] = ""
					@board.squares["E8"] = ""
					puts "0-0-0"
				elsif rook.current_position == "H8" && !white_pieces.any? {|p| legal_moves(p).include?("F8") || legal_moves(p).include?("G8")}
					rook.current_position = "F8"
					king.current_position = "G8"
					@board.squares["F8"] = rook
					@board.squares["G8"] = king
					@board.squares["E8"] = ""
					@board.squares["H8"] = ""
					puts "0-0"
				elsif white_pieces.any? {|p| legal_moves(p).include?("D8") || legal_moves(p).include?("F8")}
					puts "Illegal castle! King can't move through check."
				elsif white_pieces.any? {|p| legal_moves(p).include?("C8") || legal_moves(p).include?("G8")}
					puts "Illegal castle! King can't end in check."
				end
			end
		end
		if rook.moved
			puts "Illegal castle! The rook has already moved."
		elsif king.moved
			puts "Illegal castle! The king has already moved."
		end
	end

	def check_mate?
		white_king = @board.kings.select {|k| k.color=="white"}[0]
		black_king = @board.kings.select {|k| k.color=="black"}[0]
		if @king_in_check == white_king
			@checkmate = players.select {|p| p.color=="white"}[0]
			white_pieces = @board.squares.values.select {|p| p != "" && p.color== "white"}
			until @king_in_check == false || white_pieces.empty?
				piece = white_pieces.pop
				piece_legal_moves = legal_moves(piece)
				original_position = piece.current_position
				until @king_in_check == false || piece_legal_moves.empty?
					move = piece_legal_moves.pop
					if @board.squares[move] == ""
						piece.current_position = move
						@board.squares[move] = piece
						@board.squares[original_position] = ""
						king_in_check?
						@board.squares[original_position] = piece
						@board.squares[move] = ""
						piece.current_position = original_position
					else
						captured_piece = @board.squares[move]
						captured_piece.current_position = ""
						piece.current_position = move
						@board.squares[move] = piece
						@board.squares[original_position] = ""
						king_in_check?
						@board.squares[original_position] = piece
						@board.squares[move] = captured_piece
						piece.current_position = original_position
						captured_piece.current_position = move
					end
				end
			end
			@checkmate = false unless @king_in_check
			@king_in_check = white_king
		elsif @king_in_check == black_king
			@checkmate = players.select {|p| p.color=="black"}[0]
			black_pieces = @board.squares.values.select {|p| p != "" && p.color=="black"}
			until @king_in_check == false || black_pieces.empty?
				piece = black_pieces.pop
				piece_legal_moves = legal_moves(piece)
				original_position = piece.current_position
				until @king_in_check == false || piece_legal_moves.empty?
					move = piece_legal_moves.pop
					if @board.squares[move] == ""
						piece.current_position = move
						@board.squares[move] = piece
						@board.squares[original_position] = ""
						king_in_check?
						@board.squares[original_position] = piece
						@board.squares[move] = ""
						piece.current_position = original_position
					else
						captured_piece = @board.squares[move]
						captured_piece.current_position = ""
						piece.current_position = move
						@board.squares[move] = piece
						@board.squares[original_position] = ""
						king_in_check?
						@board.squares[original_position] = piece
						@board.squares[move] = captured_piece
						piece.current_position = original_position
						captured_piece.current_position = move
					end
				end
			end
			@checkmate = false unless @king_in_check
			@king_in_check = black_king
		end
		return @checkmate ? @checkmate : false
	end

	def offer_draw
		if @current_player == @player1
			puts "#{@player2.name}, #{@player1.name} has offered a draw. Do you accept? Type 'Y' for yes or 'N' for no."
			response = gets.chomp.upcase
			puts response == "Y" ? "Game over! It's a draw." : "Draw rejected."
		else
			puts "#{@player1.name}, #{@player2.name} has offered a draw. Do you accept? Type 'Y' for yes or 'N' for no."
			response = gets.chomp.upcase
			puts response == "Y" ? "Game over! It's a draw." : "Draw rejected."
		end
	end

	def save
		serial = YAML::dump(self)
		puts "What do you want to name the file?"
		name = gets.chomp
		savefile = File.new(File.join(__dir__, 'saves', "#{name}.txt"), 'w')
		savefile.puts serial
		savefile.close
	end

	def load
		puts "What's the name of the file you want to load?"
		name = gets.chomp
		savefile = File.open(File.join(__dir__, 'saves', "#{name}.txt"), 'r')
		contents = savefile.read
		YAML::load(contents)
	end
	
end