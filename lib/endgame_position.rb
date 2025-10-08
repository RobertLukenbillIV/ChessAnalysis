require 'sequel'

class EndgamePosition < Sequel::Model
  one_to_many :game_endgame_positions
  many_to_many :games, left_key: :endgame_position_id, right_key: :game_id, join_table: :game_endgame_positions

  def before_create
    self.created_at = DateTime.now
    self.updated_at = DateTime.now
    super
  end

  def before_update
    self.updated_at = DateTime.now
    super
  end

  def update_statistics!
    related_games = games
    self.use_count = related_games.count

    if use_count > 0
      total_score = related_games.sum(&:result_score_for_white)
      self.white_success_rate = total_score / use_count.to_f
    else
      self.white_success_rate = 0.0
    end

    save
  end

  def success_rate_percentage
    (white_success_rate * 100).round(1)
  end

  def generate_position_name
    # Generate descriptive name based on piece counts
    "#{white_pieces_count}v#{black_pieces_count}_pieces"
  end
end
