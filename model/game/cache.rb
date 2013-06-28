module NBA
  class Game < ActiveRecord::Base
    module Cache
      CACHE_PATH = "/Users/scott/data/nba/games"

      def pbp_cache_path
        # bucket games by hashing to a hex string
        bucket = cache_bucket(id)
        CACHE_PATH + "/#{bucket}/#{id}_pbp.json"
      end

      def boxscore_cache_path
        # bucket games by hashing to a hex string
        pp self if id.nil?
        bucket = cache_bucket(id)
        CACHE_PATH + "/#{bucket}/#{id}_box.json"
      end

      def cache_bucket(id)
        id[-5..-1].to_i.to_s(16)
      end
    end
  end
end
