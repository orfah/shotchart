module NBA
  class Shot < ActiveRecord::Base
    belongs_to :game
    belongs_to :player 
    belongs_to :team_for, :class_name => "Team", :foreign_key => :team_for
    belongs_to :team_against, :class_name => "Team", :foreign_key => :team_against

    # designated initializer
    def self.initialize_with_hash(hash)
      shot = self.find_by_game_id_and_game_event_id(hash[:game_id], hash[:game_event_id])
      if shot.nil?
        shot = self.new
        hash.each_pair do |key, value|
          shot.send("#{key}=", value) if shot.respond_to?("#{key}=")
        end

        shot.differential = shot.game.events.find_by_event_num(hash[:game_event_id]).differential
        shot.season = shot.game.season

        # set the team against based on the game participants
        shot.team_against = shot.game.home_team == shot.team_for ? 
          shot.game.away_team : shot.game.home_team
        shot.save
      end
      shot
    end

    # some header description transforms
    def loc_x=(x)
      self.x = x
    end

    def loc_y=(y)
      self.y = y
    end

    def team_id=(team_id)
      self.team_for = Team.find(team_id)
    end

    def shot_made_flag=(make_miss)
      self.result = make_miss == 1 ? 'make' : 'miss'
    end

    def minutes_remaining=(min)
      self.time_remaining ||= 0
      self.time_remaining += min.to_i*60
    end

    def seconds_remaining=(sec)
      self.time_remaining ||= 0
      self.time_remaining += sec
    end

    def action_type=(action)
      self.description = action
    end

    def to_hash
      { 
        game_id: game_id, 
        period: period, 
        result: result, 
        shot_type: shot_type, 
        time_remaining: time_remaining, 
        x: x, 
        y: y, 
        differential: differential, 
        description: description,
        team_for: team_for.id,
        team_against: team_against.id
      }
    end
  end

end
