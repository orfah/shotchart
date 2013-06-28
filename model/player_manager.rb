class PlayerManager
  MAX_HANDLES = 25

  def player_stats
    @player_stats ||= {
      'age' => [],
      'height' => [],
      'weight' => [],
      'years_in_league' => [],
    }
  end

  def yearly_player_stats
  
  end

  def <<(player)
    self.players << player
    if self.players.count >= MAX_HANDLES
      self.fetch
    end
  end

  def write_stats(io)
    io.write(self.stats.to_json)
  end

  def add_player_stats(players)
    players.each do |player|
      player.years.each do |year|
         
      end
    end
  end

  private
  def fetch
    multi_handle = Typhoeus::Hydra.new
    self.players.each do |p|
      # add the player profile handle
      multi_handle.queue p.multi_handle(:type => 'player')

      # grab the shot chart too
      multi_handle.queue p.multi_handle(:type => 'shot', :year => 2013)
    end

    h.run

    self.players.each do |p|
      p.commit
    end
    self.add_player_stats(players)
  end
end

http://boulder.zxq.net/stream.php?server=137&team=mia&quality=1600
