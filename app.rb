require 'sinatra'
require 'sinatra/json'
require 'sequel'
require 'json'

# Database connection
DB = Sequel.connect('sqlite://db/chess_analysis.db')

# Require models
require_relative 'lib/game'
require_relative 'lib/opening'
require_relative 'lib/endgame_position'
require_relative 'lib/chess_game_engine'

class ChessAnalysisApp < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'views'
    enable :sessions
  end

  # Routes
  get '/' do
    erb :index
  end

  get '/game' do
    session[:chess_engine] = ChessGameEngine.new
    erb :game
  end

  post '/move' do
    content_type :json

    engine = session[:chess_engine]
    return { error: 'No active game' }.to_json unless engine

    from = params[:from]
    to = params[:to]
    promotion = params[:promotion]

    result = engine.make_move(from, to, promotion)

    if result[:success]
      game_state = {
        fen: engine.current_fen,
        game_over: engine.game_over?,
        checkmate: engine.checkmate?,
        winner: engine.winner,
        is_endgame: engine.is_endgame?,
      }

      { success: true, game_state: game_state }.to_json
    else
      { success: false, error: result[:error] }.to_json
    end
  end

  post '/game/finish' do
    content_type :json

    engine = session[:chess_engine]
    return { error: 'No active game' }.to_json unless engine

    result = params[:result] # 'white_wins', 'black_wins', 'draw'

    # Save game to database
    game = Game.create(
      pgn_notation: engine.current_pgn,
      final_fen: engine.current_fen,
      result: result,
      white_pieces_count: engine.white_pieces_count,
      black_pieces_count: engine.black_pieces_count
    )

    # Process opening
    if engine.first_move_by_white
      opening = find_or_create_opening(engine)
      game.add_opening(opening)
      opening.update_statistics!
    end

    # Process endgame if applicable
    if engine.is_endgame?
      endgame_position = find_or_create_endgame_position(engine)
      game.add_endgame_position(endgame_position)
      endgame_position.update_statistics!
    end

    session[:chess_engine] = nil

    { success: true, game_id: game.id }.to_json
  end

  get '/statistics' do
    @openings = Opening.order(:use_count).reverse.all
    @endgame_positions = EndgamePosition.order(:use_count).reverse.all
    erb :statistics
  end

  get '/statistics/openings' do
    content_type :json
    openings = Opening.order(:use_count).reverse.all
    openings.map do |opening|
      {
        id: opening.id,
        opening_name: opening.opening_name,
        ten_moves_notation: opening.ten_moves_notation,
        use_count: opening.use_count,
        success_rate: opening.success_rate_percentage,
      }
    end.to_json
  end

  get '/statistics/endgame_positions' do
    content_type :json
    positions = EndgamePosition.order(:use_count).reverse.all
    positions.map do |position|
      {
        id: position.id,
        position_name: position.position_name,
        fen_notation: position.fen_notation,
        use_count: position.use_count,
        success_rate: position.success_rate_percentage,
      }
    end.to_json
  end

  get '/replay/:type/:id' do
    content_type :json

    case params[:type]
    when 'opening'
      opening = Opening[params[:id]]
      return { error: 'Opening not found' }.to_json unless opening

      {
        type: 'opening',
        moves: opening.ten_moves_notation,
        fen: opening.ten_moves_fen,
      }.to_json
    when 'endgame'
      position = EndgamePosition[params[:id]]
      return { error: 'Position not found' }.to_json unless position

      {
        type: 'endgame',
        fen: position.fen_notation,
      }.to_json
    else
      { error: 'Invalid type' }.to_json
    end
  end

  post '/import_games' do
    content_type :json

    begin
      data = JSON.parse(params[:data])
      imported_count = 0

      data['games'].each do |game_data|
        # Validate required fields
        next unless game_data['pgn_notation'] && game_data['result']

        Game.create(
          pgn_notation: game_data['pgn_notation'],
          final_fen: game_data['final_fen'],
          result: game_data['result'],
          white_pieces_count: game_data['white_pieces_count'],
          black_pieces_count: game_data['black_pieces_count']
        )

        imported_count += 1
      end

      { success: true, imported_count: imported_count }.to_json
    rescue JSON::ParserError
      { success: false, error: 'Invalid JSON format' }.to_json
    rescue StandardError => e
      { success: false, error: e.message }.to_json
    end
  end

  get '/export_games' do
    content_type :json

    games = Game.all
    export_data = {
      export_date: DateTime.now.iso8601,
      games: games.map do |game|
        {
          id: game.id,
          pgn_notation: game.pgn_notation,
          final_fen: game.final_fen,
          result: game.result,
          white_pieces_count: game.white_pieces_count,
          black_pieces_count: game.black_pieces_count,
          created_at: game.created_at&.iso8601,
        }
      end,
    }

    export_data.to_json
  end

  private

  def find_or_create_opening(engine)
    opening_name = engine.first_move_by_white
    ten_moves = engine.first_ten_moves

    opening = Opening.find(opening_name: opening_name, ten_moves_notation: ten_moves)

    opening ||= Opening.create(
      opening_name: opening_name,
      ten_moves_notation: ten_moves,
      ten_moves_fen: engine.current_fen # This would need to be the FEN after 10 moves
    )

    opening
  end

  def find_or_create_endgame_position(engine)
    fen = engine.current_fen
    white_count = engine.white_pieces_count
    black_count = engine.black_pieces_count

    position = EndgamePosition.find(fen_notation: fen)

    position ||= EndgamePosition.create(
      position_name: "#{white_count}v#{black_count}_pieces",
      fen_notation: fen,
      white_pieces_count: white_count,
      black_pieces_count: black_count
    )

    position
  end
end

# Start the application
ChessAnalysisApp.run! if __FILE__ == $0
