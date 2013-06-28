module NBA
  module Requests
    def fetch(id, options={})
      self.id = id
      puts "fetching for id #{id}"
      pp self
#      self.methods.grep(/.*_cache_path/).each do |cache_path|
#        puts cache_path
#        puts send(cache_path)
#      end
#      exit
      options.merge!({ followlocation: true, forbid_reuse: true })
      h = Typhoeus::Hydra.new
      self.methods.grep(/.*_multi_handle/).each do |handle_function|
        h.queue self.send(handle_function, options)
      end
      h.run
    end

    def request(url, cache_path, options)
      req = Typhoeus::Request.new(url, options)
      req.on_complete { |response| write_cache(cache_path, response) }
      req
    end
  end
end
