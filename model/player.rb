require_relative 'utilities/requests'
require_relative 'utilities/cache'
require_relative 'utilities/parsers'

require_relative 'player/requests'
require_relative 'player/cache'
require_relative 'player/parsers'

module NBA
  class Player < ActiveRecord::Base
    has_many :shots
    # has_many :games, :through => :shots

    include NBA::Requests
    include NBA::Cache
    include NBA::Parsers
    include Player::Requests
    include Player::Cache
    include Player::Parsers

    # designated initializer
    def self.find_or_import(player_id, options={})
      player = self.find_by_id(player_id)
      if player.nil?
        player = self.new
        player.fetch(player_id, options)

        player.parse(options)

        player.assign_profile
        player.save
      end

      player
    end

    # import all aspects of the player, including shot chart and games. If multiple
    # players need to be imported, will try to import all of them as well, be 
    # careful.
    def self.find_with_full_initialize!(player_id, options={})
      options.merge!({parse_all: true})
      player = self.find_or_import(player_id, options)
      player.parse(options)
    end

    #
    # utilities
    #
    def full_name
      first_name + ' ' + last_name
    end

    def convert_height(height)
      if height.respond_to?(:split)
        feet, inches = height.split('-')
        height = feet.to_i * 12 + inches.to_i
      end
      height
    end

    def sanitize_profile
      sanitized_profile = sanitize_keys(@profile)
      sanitized_profile['height'] = convert_height(sanitized_profile['height'])
      sanitized_profile['birthdate'] = date_to_unixtime(sanitized_profile['birthdate'])

      @profile = sanitized_profile
    end

    def sanitize_keys(hash)
      sanitized_hash = {}
      hash.each_pair do |key, val|
        new_key = snake_case(key).downcase
        if val.is_a? Hash
          sanitized_hash[new_key] = sanitize_keys(val)
        elsif val.is_a? Array
          sanitized_hash[new_key] = []
          val.each { |v| sanitized_hash[new_key] << sanitize_keys(v) }
        else
          val = val.to_i if val.is_a? String and not val.match('\D')
          sanitized_hash[new_key] = val
        end
      end

      sanitized_hash
    end

    def assign_profile
      sanitize_profile
      # assign profile as applicable
      @profile.each_pair do |key, value|
        send("#{key}=", value) if self.respond_to?("#{key}=")
      end
    end

  end
end
