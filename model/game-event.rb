module NBA
  class GameEvent < ActiveRecord::Base
    belongs_to :game
    KEY_MAP = {
      'eventnum' => :event_num, 
      'eventmsgtype' => :event_type,
      'pctimestring' => :time,
    }

    def self.find_or_import(event_hash)
      game_id = event_hash[:game_id]
      event_num = event_hash[:event_num]
      event = self.find_by_game_id_and_event_num(game_id, event_num)

      if event.nil?
        event = self.new
        event_hash.each_pair do |key, value|
          key = KEY_MAP[key] if KEY_MAP.include? key
          event.send("#{key}=", value) if event.respond_to?("#{key}=")
        end
        event.save
      end

      event
    end

    # conversion functions
    def score=(s)
      unless s.to_s.empty?
        self.home_score, self.away_score = s.split(' - ')
      end
    end

    def time=(t)
      min, secs = t.split(':')
      self.time_remaining = min.to_i * 60 + secs.to_i
    end

    def differential
      (home_score - away_score).abs unless home_score.nil?
    end
  end
end
