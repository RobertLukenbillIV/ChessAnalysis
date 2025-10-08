require 'sequel'

# Connect to SQLite database
DB = Sequel.connect('sqlite://db/chess_analysis.db')

# Create tables
DB.create_table? :games do
  primary_key :id
  String :pgn_notation, text: true
  String :final_fen, text: true
  String :result # 'white_wins', 'black_wins', 'draw'
  Integer :white_pieces_count
  Integer :black_pieces_count
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :openings do
  primary_key :id
  String :opening_name
  String :ten_moves_notation, text: true
  String :ten_moves_fen, text: true
  Integer :use_count, default: 0
  Float :white_success_rate, default: 0.0
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :endgame_positions do
  primary_key :id
  String :position_name
  String :fen_notation, text: true
  Integer :white_pieces_count
  Integer :black_pieces_count
  Integer :use_count, default: 0
  Float :white_success_rate, default: 0.0
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table? :game_openings do
  primary_key :id
  foreign_key :game_id, :games
  foreign_key :opening_id, :openings
end

DB.create_table? :game_endgame_positions do
  primary_key :id
  foreign_key :game_id, :games
  foreign_key :endgame_position_id, :endgame_positions
end

puts "Database tables created successfully!"