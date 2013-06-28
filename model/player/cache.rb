module NBA
  class Player < ActiveRecord::Base
    module Cache
      CACHE_PATH = "/Users/scott/data/nba/players"

      def cache_bucket(id)
        bucket = id.to_s(16)
        # awkward...left padding with 0 for a string
        if bucket.length < 2 
          '0' * (2 - bucket.length) + bucket
        else
          bucket[-2..-1]
        end
      end

      def shot_cache_path(year)
        CACHE_PATH + "/#{cache_bucket(id)}/#{id}/shotcharts/#{year}.json"
      end

      def player_cache_path
        CACHE_PATH + "/#{cache_bucket(id)}/#{id}/player.json"
      end

      def awards_cache_path
        CACHE_PATH + "/#{cache_bucket(id)}/#{id}/awards.json"
      end

      def profile_cache_path
        CACHE_PATH + "/#{cache_bucket(id)}/#{id}/profile.json"
      end

    end
  end
end
